module Retailers::Api::V1
  class AgentSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :email, :retailer_id, :admin, :pending_payment?

    def admin
      object.retailer_admin
    end

    def pending_payment?
      PaymentPlan.find_by_retailer_id(object.retailer_id).status_inactive?
    end
  end
end
