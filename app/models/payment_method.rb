class PaymentMethod < ApplicationRecord
  belongs_to :retailer
  has_many :stripe_transactions

  validates :stripe_pm_id, :retailer, :payment_type, :payment_payload, presence: true

  after_commit :set_default, on: :create

  default_scope -> { where(deleted: false).order(main: :desc) }

  scope :main, -> { find_by(main: true) }

  def card_type
    JSON.parse(payment_payload).try(:[], 'card').try(:[], 'brand')
  end

  def delete_card!
    return unless update(deleted: true) && main

    retailer.payment_methods.order(id: :desc).first.update_column(:main, true)
  end

  def set_default
    retailer.payment_methods.update_all(main: false)
    update_column(:main, true)
  end
end
