module Retailers::Api::V1
  class WhatsappTemplatesController < Retailers::Api::V1::ApiController
    def index
      templates = current_retailer.whatsapp_templates

      render status: 200, json: {
        templates: serialize_whatsapp_templates(templates)
      }
    end

    private

      def serialize_whatsapp_templates(templates)
        ActiveModelSerializers::SerializableResource.new(
          templates,
          each_serializer: Retailers::Api::V1::WhatsappTemplateSerializer
        ).as_json
      end
  end
end
