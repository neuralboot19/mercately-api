module Retailers::Api::V1
  class FacebookMessageSerializer < ActiveModel::Serializer
    attributes :text, :sent_by_retailer, :file_type, :filename,
               :sent_from_mercately, :url, :date_read, :created_at

    def id
      object.mid
    end

    def url
      object.url&.gsub('http:', 'https:')
    end
  end
end
