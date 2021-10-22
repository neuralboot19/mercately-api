module Api::V1
  class GsTemplateSerializer < ActiveModel::Serializer
    include FastJsonapi::ObjectSerializer

    attributes :id, :label, :language, :category, :text, :example, :key
  end
end
