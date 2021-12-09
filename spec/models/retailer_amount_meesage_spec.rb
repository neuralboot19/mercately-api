require 'rails_helper'

RSpec.describe RetailerAmountMessage, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:calculation_date) }
  end
end