module Retailers::Api::V1
  class RetailerSerializer < ActiveModel::Serializer
    attributes :slug, :unique_key, :catalog_slug
  end
end
