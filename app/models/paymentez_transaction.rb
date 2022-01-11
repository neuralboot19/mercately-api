class PaymentezTransaction < ApplicationRecord
  include WebIdGenerateableConcern
  include PaymentezConcern

  belongs_to :retailer
  belongs_to :paymentez_credit_card

  after_create :generate_web_id

  def to_param
    web_id
  end

  def debit_with_token(card, amount = nil, plan = nil, sub = false)
    self.month_interval = sub ? retailer.payment_plan.month_interval : 0
    retailer = card.retailer
    retailer_plan = retailer.payment_plan
    if plan.present?
      retailer_plan.plan = plan
      retailer_plan.status = 'active'
      retailer_plan.next_pay_date = 30.days.from_now
    end

    debit_response = request_debit(card, amount, retailer_plan)
    body = JSON.parse(debit_response.body)

    if body['transaction']['status'] == 'failure'
      message = 'La transacción no pudo ser procesada'
      return return_hash(400, message)
    end

    prepare_new_transaction(body, card)
    if debit_response.status == 200 && save
      if retailer_plan.save
        # send the email notification
        PaymentezTransactionMailer.debit_success(self).deliver_later

        message = 'Transacción procesada satisfactoriamente'
        return return_hash(debit_response.status, message)
      end

      message = "La transacción fue procesada,
                 pero hubo errores al
                 almacenar: #{errors.full_messages}"
      return return_hash(400, message)
    end

    # send the email notification
    PaymentezTransactionMailer.debit_failure(self).deliver_later

    message = "Transacción no pudo
               ser procesada: #{debit_response.body.to_json}"
    return_hash(debit_response.status, message)
  end

  def refund
    refund_response = request_refund

    if refund_response.status == 200
      update(status: 'refund')
      # send the email notification
      PaymentezTransactionMailer.refund_success(self).deliver_later

      message = 'Transacción devuelta satisfactoriamente'
      return return_hash(refund_response.status, message)
    end

    # send the email notification
    PaymentezTransactionMailer.refund_failure(self).deliver_later

    message = "Transacción no pudo ser devuelta: #{refund_response.body.to_json}"
    return_hash(refund_response.status, message)
  end

  private

    def prepare_new_transaction(body, card)
      self.status = body['transaction']['status']
      self.payment_date = body['transaction'].try(:[],'payment_date')
      self.amount = body['transaction'].try(:[],'amount')
      self.authorization_code = body['transaction'].try(:[],'authorization_code')
      self.installments = body['transaction'].try(:[],'installments')
      self.dev_reference = body['transaction'].try(:[],'dev_reference')
      self.message = body['transaction'].try(:[],'message')
      self.carrier_code = body['transaction'].try(:[],'carrier_code')
      self.pt_id = body['transaction'].try(:[],'id')
      self.status_detail = body['transaction'].try(:[],'status_detail')
      self.transaction_reference = body['card'].try(:[],'transaction_reference')
      self.retailer_id = card.retailer_id
      self.payment_plan_id = card.retailer.payment_plan_id
      self.paymentez_credit_card_id = card.id
    end

    def build_debit_body(card, amount = nil, plan = nil)
      retailer = card.retailer
      price = (amount || plan.price).round(2)

      # IVA calculation
      vat = (price * 0.12).round(2)

      '{
        "user": {
          "id": "' + retailer.id.to_s + '",
          "email": "' + retailer.admins.first.email + '"
        },
        "order": {
          "amount": ' + (price.round(2) + vat).round(2).to_s + ',
          "description": "' + plan.plan + '",
          "dev_reference": "' + plan.id.to_s + '",
          "tax_percentage": 12,
          "taxable_amount": ' + price.round(2).to_s + ',
          "vat": ' + vat.to_s + '
        },
        "card": {
          "token": "' + card.token.to_s + '"
        }
      }'
    end

    def request_debit(card, amount = nil, plan = nil)
      debit_body = build_debit_body(card, amount, plan)
      url = '/v2/transaction/debit/'

      # Makes the payment request to Paymentez
      self.class.do_request('post', debit_body, url)
    end

    def build_refund_body
      '{
        "transaction": {
          "id": "' + pt_id + '"
        }
      }'
    end

    def request_refund
      refund_body = build_refund_body
      url = '/v2/transaction/refund/'

      # Makes the refund request to Paymentez
      self.class.do_request('post', refund_body, url)
    end

    def return_hash(status, message)
      { status: status, message: message }
    end
end
