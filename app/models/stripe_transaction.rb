class StripeTransaction < ApplicationRecord
  belongs_to :retailer
  belongs_to :payment_method

  validates :amount, numericality: { greater_than_or_equal_to: 10 }

  before_create :create_payment
  after_create :recharge_balance

  private

    def create_payment
      charge = Stripe::PaymentIntent.create(
        confirm: true,
        currency: 'usd',
        amount: amount * 100,
        description: 'Recarga de saldo',
        payment_method: payment_method.stripe_pm_id,
        customer: JSON.parse(payment_method.payment_payload)['customer']
      )
      self.stripe_id = charge.id
    rescue StandardError => e
      Raven.capture_exception(e)
      errors.add(:base, 'Error al añadir saldo')
      throw :abort
    end

    def recharge_balance
      TopUp.create(
        retailer: payment_method.retailer,
        amount: amount
      )
    end
end
