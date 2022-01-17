require 'rails_helper'

RSpec.describe RetailerAverageResponseTime, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:retailer_user).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:calculation_date) }
    it { is_expected.to validate_presence_of(:platform) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:platform).with_values(%i[whatsapp messenger instagram]) }
  end
end