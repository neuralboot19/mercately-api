module Retailers::Api::V1
  class FacebookMessageSerializer < ActiveModel::Serializer
    attributes :text, :sent_by_retailer, :file_type, :filename,
               :sent_from_mercately, :message_identifier, :date_read, :created_at, :url

    def id
      object.mid
    end

    def url
      object.url&.gsub('http:', 'https:')
    end
  end
end
