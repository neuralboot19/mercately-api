module Retailers::Api::V1
  class CustomerSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :email, :phone, :meli_customer_id, :meli_nickname, :id_type,
    :id_number, :address, :city, :state, :zip_code, :country_id, :notes, :whatsapp_opt_in, :whatsapp_name,
    :tags, :custom_fields

    def id
      object.web_id
    end

    def tags
      object.tags.as_json(only: [:tag, :web_id])
    end

    def custom_fields
      c_data = []
      object.customer_related_data.each do |data|
        c_data << {
          'field_name': data.customer_related_field.identifier,
          'field_content:': data.data
        }
      end
      return c_data
    end
  end
end
