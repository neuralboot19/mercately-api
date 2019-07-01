class Category < ApplicationRecord
  has_ancestry
  has_many :products

  validates :meli_id, uniqueness: true
  validates :name, presence: true

  def clean_template_variations
    template.reject { |temp| temp['tags']['fixed'] == true ||
      temp['tags']['hidden'] == true || temp['tags']['read_only'] == true ||
      temp['tags']['restricted_values'] == true }
  end
end
