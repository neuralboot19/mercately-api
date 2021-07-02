class Deal < ApplicationRecord
  include WebIdGenerateableConcern
  belongs_to :retailer
  belongs_to :funnel_step
  belongs_to :customer, optional: true
  belongs_to :retailer_user

  validates :name, presence: true

  after_create :generate_web_id
  after_create :validate_customer_deals
  after_destroy :validate_customer_deals
  #TODO ADD SPECS
  def validate_customer_deals
    return unless customer
    if customer.deals.count > 0
      customer.update_columns(has_deals: true)
    else
      customer.update_columns(has_deals: false)
    end
  end
end
