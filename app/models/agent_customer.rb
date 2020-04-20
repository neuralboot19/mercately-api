class AgentCustomer < ApplicationRecord
  belongs_to :retailer_user
  belongs_to :customer
end
