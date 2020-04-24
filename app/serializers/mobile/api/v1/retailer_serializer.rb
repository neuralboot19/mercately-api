module Mobile::Api::V1
  class RetailerSerializer
    include FastJsonapi::ObjectSerializer

    set_type :retailer
    set_id :id

    attributes :id, :name, :slug
  end
end
