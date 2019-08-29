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
      attributes << temp if (temp['tags']['allow_variations'] ||
                            temp['tags']['catalog_required'] ||
                            temp['tags']['required']) && check_not_used_attr(temp)
    end

    attributes
  end

  private

    def check_not_used_attr(temp)
      temp['tags']['hidden'].blank? &&
        temp['tags']['fixed'].blank? && temp['tags']['inferred'].blank? &&
        temp['tags']['others'].blank? && temp['tags']['read_only'].blank? &&
        temp['tags']['restricted_values'].blank?
    end
end
