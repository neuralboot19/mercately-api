require 'rails_helper'

RSpec.describe RetailerConversation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:retailer_user).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:calculation_date) }
  end
end