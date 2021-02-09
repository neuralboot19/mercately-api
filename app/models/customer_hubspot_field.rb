class CustomerHubspotField < ApplicationRecord
  belongs_to :hubspot_field
  belongs_to :retailer

  validate :same_field_type
  validates :customer_field, uniqueness: { scope: [:retailer_id, :hubspot_field_id] }

  after_save :set_hubspot_field_taken
  after_save :save_tags
  after_commit :update_hubspot, on: :create
  after_destroy :set_hubspot_field_not_taken

  private

    def set_hubspot_field_taken
      return false if hubspot_field_id.blank?

      hubspot_field.update(taken: true)
    end

    def set_hubspot_field_not_taken
      return false if hubspot_field_id.blank?

      hubspot_field.update(taken: false)
    end

    def save_tags
      return if customer_field != 'tags'

      retailer.update(hs_tags: true)
    end

    def same_field_type
      return if customer_field == 'tags'

      field_type = Customer.columns_hash[customer_field]&.type ||
        CustomerRelatedField.find_by(retailer: retailer, name: customer_field)&.field_type
      return false if field_type.nil?

      field_type = field_type.to_s
      valid_field = case hubspot_field.hubspot_type
                    when 'datetime', 'date'
                      ['datetime', 'date'].include? field_type
                    when 'number', 'enumeration', 'phone_number'
                      ['integer', 'float'].include? field_type
                    when 'bool'
                      field_type == 'boolean'
                    else
                      true
                    end
      return true if valid_field

      errors.add(:base, 'Los campos deben ser del mismo tipo')
    end

    def update_hubspot
      HsUpdateFieldJob.perform_later(id)
    end
end
