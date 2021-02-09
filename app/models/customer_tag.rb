class CustomerTag < ApplicationRecord
  belongs_to :tag
  belongs_to :customer

  after_commit :sync_tags
  after_destroy :sync_tags

  private

    def sync_tags
      return unless customer.retailer.hs_tags
      return if hubspot.nil? || customer.retailer.hs_access_token.blank?

      hs_tag_field = customer.retailer.customer_hubspot_fields.find_by(customer_field: 'tags')
      hubspot.contact_update(
        customer.hs_id,
        "#{hs_tag_field.hubspot_field.hubspot_field}": customer.tags.pluck(:tag).join(', ')
      )
    end

    def hubspot
      @hubspot = HubspotService::Api.new(customer.retailer.hs_access_token)
    end
end
