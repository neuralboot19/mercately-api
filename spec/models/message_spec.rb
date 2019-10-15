require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:sender).with_foreign_key(:sender_id).class_name('RetailerUser').optional }
  end

  describe 'delegates' do
    it { is_expected.to delegate_method(:retailer_id).to(:customer) }
    it { is_expected.to delegate_method(:retailer).to(:customer) }
  end
end
