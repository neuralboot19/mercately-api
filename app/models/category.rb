class Category < ApplicationRecord
  has_ancestry
  has_many :products

  validates :meli_id, uniqueness: true
  validates :name, presence: true

  enum status: %w[active inactive]

  def required_product_attributes
    template.map do |temp|
      temp['id'] if temp['tags']['allow_variations'].blank? &&
                                  (temp['tags']['catalog_required'] ||
                                  temp['tags']['required']) && check_not_used_attr(temp)
    end.compact
  end

  def clean_template_variations
    template.map do |temp|
      temp if (temp['tags']['allow_variations'] ||
                            temp['tags']['catalog_required'] ||
                            temp['tags']['required']) && check_not_used_attr(temp)
    end.compact
  end

  private

    def check_not_used_attr(temp)
      temp['tags']['hidden'].blank? &&
        temp['tags']['fixed'].blank? && temp['tags']['inferred'].blank? &&
        temp['tags']['others'].blank? && temp['tags']['read_only'].blank? &&
        temp['tags']['restricted_values'].blank?
    end
end
