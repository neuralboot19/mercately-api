module Api::V1
  class RetailerUserSerializer
    include FastJsonapi::ObjectSerializer

    set_type :retailer_user
    set_id :id

    attributes :id, :email, :first_name, :last_name

    attribute :admin do |ru|
      ru.admin?
    end

    attribute :supervisor do |ru|
      ru.supervisor?
    end

    belongs_to :retailer

    attribute :retailer_integration do |ru|
      ru.retailer.karix_integrated? ? '0' : '1'
    end
  end
end
