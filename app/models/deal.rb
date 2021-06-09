class Deal < ApplicationRecord
  include WebIdGenerateableConcern
  belongs_to :retailer
  belongs_to :funnel_step
  belongs_to :customer, optional: true
  belongs_to :retailer_user

  validates :name, presence: true

  after_create :generate_web_id
end
