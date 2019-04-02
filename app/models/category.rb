class Category < ApplicationRecord
  has_ancestry
  has_many :products

  validates :meli_id, uniqueness: true
  validates :name, presence: true
end
