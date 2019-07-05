class Template < ApplicationRecord
  belongs_to :retailer
  validates :title, :answer, presence: true
end
