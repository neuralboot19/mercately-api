class RuleCategory < ApplicationRecord
  validates :name, presence: true

  has_many :business_rules, dependent: :destroy

  accepts_nested_attributes_for :business_rules, reject_if: :all_blank, allow_destroy: true
end
