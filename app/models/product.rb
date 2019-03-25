class Product < ApplicationRecord
  belongs_to :retailer
  has_many :orders, dependent: :destroy
  has_many_attached :images

  def ml_condition
    %w[new used not_specified]
  end
end
