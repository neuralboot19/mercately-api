class BusinessRule < ApplicationRecord
  belongs_to :rule_category
  validates_presence_of :name, :description, :identifier
  validates_uniqueness_of :identifier

  has_many :retailer_business_rules, dependent: :destroy
end
