module Retailers::Api::V1
  class ProductSerializer < ActiveModel::Serializer
    attributes :id, :title, :price, :url, :available_quantity, :description, :status

    def id
      object.web_id
    end
  end
end
