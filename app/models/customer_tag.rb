class CustomerTag < ApplicationRecord
  belongs_to :tag
  belongs_to :customer

  validates :tag, uniqueness: { scope: :customer, message: 'Etiqueta ya está asignada al cliente.' }

  after_commit :sync_tags, on: :create
  after_commit :remove_hs_value, on: :destroy

  private

    def sync_tags
      return unless customer.retailer.hs_tags
      return if hubspot.nil? || customer.retailer.hs_access_token.blank?

      hs_tag_fields = customer.retailer.customer_hubspot_fields.where(hs_tag: true, customer_field: tag.tag)
      params = {}
      hs_tag_fields.each do |hs_tag_field|
        params[hs_tag_field.hubspot_field.hubspot_field] = tag.tag
      end
      hubspot.contact_update(
        customer.hs_id,
        params
      )
    end

    def remove_hs_value
      return unless customer.retailer.hs_tags
      return if hubspot.nil? || customer.retailer.hs_access_token.blank?

      hs_tag_fields = customer.retailer.customer_hubspot_fields.where(hs_tag: true, customer_field: tag.tag)
      params = {}
      hs_tag_fields.each do |hs_tag_field|
        next if hs_tag_field.hubspot_field.hubspot_field.blank?

        params[hs_tag_field.hubspot_field.hubspot_field] = ''.freeze
      end
      return if params.empty?

      hubspot.contact_update(
        customer.hs_id,
        params
      )
    end

    def hubspot
      @hubspot = HubspotService::Api.new(customer.retailer.hs_access_token)
    end
end
