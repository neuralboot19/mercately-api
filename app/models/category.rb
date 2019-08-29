class Category < ApplicationRecord
  has_ancestry
  has_many :products

  validates :meli_id, uniqueness: true
  validates :name, presence: true

  enum status: %w[active inactive]

  scope :active_categories, -> { where('categories.status = 0') }

  def clean_template_variations
    attributes = []
    template.each do |temp|
      attributes << temp if
        temp['tags']['allow_variations'] || temp['tags']['catalog_required'] || temp['tags']['required']
    end

    attributes
  end
end
