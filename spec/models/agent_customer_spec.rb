require 'rails_helper'

RSpec.describe AgentCustomer, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer_user) }
    it { is_expected.to belong_to(:customer) }
  end
end
