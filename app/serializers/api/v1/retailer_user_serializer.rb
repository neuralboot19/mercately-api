module Api::V1
  class RetailerUserSerializer
    include FastJsonapi::ObjectSerializer

    set_type :retailer_user
    set_id :id

    attributes :id, :email, :first_name, :last_name

    attribute :admin do |ru|
      ru.admin?
    end

    belongs_to :retailer
  end
end
