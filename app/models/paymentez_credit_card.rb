class PaymentezCreditCard < ApplicationRecord
  include PaymentezConcern

  belongs_to :retailer
  has_many :paymentez_transactions, dependent: :destroy

  before_save :set_default
  before_destroy :erase_from_paymentez

  default_scope -> { where(deleted: false).order(main: :desc) }

  def create_transaction
    plan = self.retailer.payment_plan
    return true if plan.plan == 'free' || plan.price.zero?

    response = transaction.debit_with_token(self)
    plan.update(status: :inactive) and return false if response[:status] != 200

    next_pay_date = plan.next_pay_date ? plan.next_pay_date : Date.today + 30.days
    plan.update(next_pay_date: next_pay_date) if plan.next_pay_date != Date.today

    schedule_payment(next_pay_date.end_of_day) unless Rails.env == 'test'
    true
  end

  def create_transaction_with_amount(amount)
    return false unless amount.present? || amount < 10.0

    response = transaction.debit_with_token(self, amount)
    return false unless response[:status] == 200

    new_balance = self.retailer.ws_balance + amount
    self.retailer.update(ws_balance: new_balance)

    true
  end

  def create_transaction_with_plan(purchase)
    amount = purchase[:amount].to_f
    plan = purchase[:plan]

    return false unless amount.present? && plan.present?

    response = transaction.debit_with_token(self, amount, plan)
    return false unless response[:status] == 200

    plan = self.retailer.payment_plan
    next_pay_date = plan.next_pay_date + 30.days
    plan.update(
      next_pay_date: next_pay_date,
      price: amount
    )

    schedule_payment(next_pay_date.end_of_day) unless Rails.env == 'test'
    true
  end

  def delete_card!
    update(deleted: true)
    erase_from_paymentez
  end

  def erase_from_paymentez
    url = '/v2/card/delete/'
    body = '{"card": { "token": "' + self.token.to_s + '" }, "user": { "id": "' + self.retailer.id.to_s + '" }}'
    response = self.class.do_request('post', body, url)

    Rails.logger.info(response.body)
    return true if response.status == 200

    update(deleted: false)
    errors.add(:base, 'Error al borrar tarjeta')
    throw(:abort)
  end

  def set_default
    return true if self.retailer.main_paymentez_credit_card.present?
    self.main = true
  end

  def self.erase_from_paymentez_with_id(id, token)
    url = '/v2/card/delete/'
    body = '{"card": { "token": "' + token.to_s + '" }, "user": { "id": "' + id.to_s + '" }}'
    response = self.do_request('post', body, url)

    Rails.logger.info(response.body)
    return false unless response.status == 200
    true
  end

  def self.card_list
    body = '{}'
    (1..1000).each do |index|
      url = "/v2/card/list/?uid=#{index}"
      response = self.do_request('get', body, url)

      Rails.logger.info(response.body)
    end
  end

  private
    def transaction
      PaymentezTransaction.new()
    end

    def schedule_payment(payment_date)
      Retailers::RetailerChargePlanJob.perform_at(
        payment_date,
        self.id
      )
    end
end
