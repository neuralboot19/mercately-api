class CustomerRelatedDatum < ApplicationRecord
  belongs_to :customer
  belongs_to :customer_related_field
  after_update :sync_hs

  private

    def hubspot
      return unless customer.hs_active?

      @hubspot = HubspotService::Api.new(customer.retailer.hs_access_token)
    end

    def sync_hs
      return unless customer.hs_active?

      chf = CustomerHubspotField.find_by(
        retailer: customer.retailer,
        customer_field: customer_related_field.name
      )
      return if chf.nil?

      hubspot.contact_update(customer.hs_id, "#{chf.hubspot_field.hubspot_field}": data)
    end
end
