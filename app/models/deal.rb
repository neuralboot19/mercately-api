class Deal < ApplicationRecord
  include WebIdGenerateableConcern
  belongs_to :retailer
  belongs_to :funnel_step
  belongs_to :customer, optional: true

  validates :name, presence: true

  after_create :generate_web_id
end
