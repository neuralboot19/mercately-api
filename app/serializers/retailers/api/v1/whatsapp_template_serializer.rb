module Retailers::Api::V1
  class WhatsappTemplateSerializer < ActiveModel::Serializer
    attributes :text, :status, :template_type, :internal_id

    def internal_id
      object.gupshup_template_id
    end
  end
end
