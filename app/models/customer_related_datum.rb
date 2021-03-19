class CustomerRelatedDatum < ApplicationRecord
  belongs_to :customer
  belongs_to :customer_related_field
  after_commit :sync_hs, on: [:create, :update]

  def get_list_value
    return data unless customer_related_field.list?

    customer_related_field.list_options.find { |l| l.key == data }&.value
  end

  private

    def hubspot
      return unless customer.hs_active?

      @hubspot = HubspotService::Api.new(customer.retailer.hs_access_token)
    end

    def sync_hs
      return unless customer.hs_active?
      return if customer.hs_id.blank?

      chf = CustomerHubspotField.find_by(
        retailer: customer.retailer,
        customer_field: customer_related_field.identifier
      )
      return if chf.nil?

      hubspot.contact_update(customer.hs_id, "#{chf.hubspot_field.hubspot_field}": data)
    end
end
