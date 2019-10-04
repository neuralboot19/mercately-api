require 'rails_helper'

RSpec.describe MeliRetailer, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
  end

  describe '.check_unique_retailer_id' do
    
  end
end
