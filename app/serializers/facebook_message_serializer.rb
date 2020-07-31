class FacebookMessageSerializer < ActiveModel::Serializer
  attributes :id, :customer_id, :text, :created_at, :date_read, :sent_by_retailer, :file_type,
             :filename, :sent_from_mercately, :url

  def url
    object.url&.gsub('http:', 'https:')
  end
end
