class StripeTransaction < ApplicationRecord
  belongs_to :retailer
  belongs_to :payment_method, optional: true

  validates :amount, numericality: { greater_than_or_equal_to: 10 }

  before_create :create_payment
  after_create :recharge_balance, unless: :create_charge

  attr_writer :create_charge

  def create_charge
    @create_charge || false
  end

  private

    def create_payment
      desc = 'Recarga de saldo'
      err = 'Error al añadir saldo'
      if create_charge
        desc = 'Pago cuota'
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
