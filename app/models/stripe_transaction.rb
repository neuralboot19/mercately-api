class StripeTransaction < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  belongs_to :payment_method, optional: true

  validates :amount, numericality: { greater_than_or_equal_to: 10 }

  before_create :create_payment
  after_create :recharge_balance, unless: :create_charge
  after_create :generate_web_id

  attr_writer :create_charge

  def to_param
    web_id
  end

  def create_charge
    @create_charge || false
  end

  private

    def create_payment
      desc = 'Recarga de saldo'
      err = 'Error al añadir saldo'
      self.month_interval = 0
      if create_charge
        self.month_interval = retailer.payment_plan.month_interval
        desc = if month_interval > 1
                 "Mercately #{month_interval} Months Subscription"
               else
                 'Mercately Monthly Subscription'
               end
        err = 'Error al procesar el pago, retailer desactivado'
      end
      charge = Stripe::PaymentIntent.create(
        confirm: true,
        currency: 'usd',
        amount: amount * 100,
        description: desc,
        payment_method: payment_method.stripe_pm_id,
        customer: JSON.parse(payment_method.payment_payload)['customer']
      )
      self.stripe_id = charge.id
    rescue StandardError => e
      Raven.capture_exception(e)
      errors.add(:base, err)
      throw :abort
    end

    def recharge_balance
      TopUp.create(
        retailer: payment_method.retailer,
        amount: amount
      )
    end
end
