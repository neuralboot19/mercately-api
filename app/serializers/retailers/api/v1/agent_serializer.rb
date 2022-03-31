module Retailers::Api::V1
  class AgentSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :email, :retailer_id, :mobile_type, :app_version, :active,
               :admin, :pending_payment?, :currency, :ws_balance, :retailer

    def admin
      object.retailer_admin
    end

    def pending_payment?
      PaymentPlan.find_by_retailer_id(object.retailer_id).status_inactive?
    end

    def currency
      object.retailer.currency_symbol
    end

    def ws_balance
      object.retailer.ws_balance
    end

    def retailer
      RetailerSerializer.new(object.retailer)
    end
  end
end
