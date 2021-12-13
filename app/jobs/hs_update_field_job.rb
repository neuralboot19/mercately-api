class HsUpdateFieldJob < ApplicationJob
  queue_as :default

  def perform(chf_id)
    @chf = CustomerHubspotField.find(chf_id)
    @retailer = @chf.retailer
    customer_field = @chf.customer_field
    if Customer.columns_hash[customer_field]
      @retailer.customers.where(hs_active: true).where.not(hs_id: nil).find_each do |c|
        next if c.send(customer_field).blank?

        hubspot.contact_update(c.hs_id, "#{@chf.hubspot_field.hubspot_field}": c.send(customer_field))
        sleep 0.1
      end
    elsif @chf.hs_tag
      @retailer.customers.includes(:tags).where(hs_active: true, tags: { tag: customer_field }).where.not(hs_id: nil).find_each do |c|
        hs_tag_fields = @retailer.customer_hubspot_fields.where(hs_tag: true, customer_field: customer_field)
        params = {}
        hs_tag_fields.each do |hs_tag_field|
          params[hs_tag_field.hubspot_field.hubspot_field] = customer_field
        end
        hubspot.contact_update(c.hs_id, params)
        sleep 0.1
      end
    elsif CustomerRelatedField.find_by(retailer: @retailer, identifier: customer_field)
      crf = CustomerRelatedField.find_by(retailer: @retailer, identifier: customer_field)
      @retailer.customers.where(hs_active: true).where.not(hs_id: nil).find_each do |c|
        crf.customer_related_data.where(customer: c).each do |crd|
          next if crd.data.blank?

          hubspot.contact_update(c.hs_id, "#{@chf.hubspot_field.hubspot_field}": crd.data)
          sleep 0.1
        end
      end
    end
  rescue StandardError
    chf = CustomerHubspotField.find(chf_id)
    retailer = chf.retailer
    HubspotService::Api.notify_broken_integration(retailer)
  end

  private

    def hubspot
      @hubspot = HubspotService::Api.new(@retailer.hs_access_token)
    end
end
