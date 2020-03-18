class FacebookMessageSerializer < ActiveModel::Serializer
  attributes :id, :customer_id, :text, :created_at, :date_read, :sent_by_retailer, :url, :file_type,
             :filename
end
