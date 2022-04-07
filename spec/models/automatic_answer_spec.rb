require 'rails_helper'

RSpec.describe AutomaticAnswer, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:retailer) }
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_presence_of(:message_type) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { should have_many(:automatic_answer_days) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:message_type).with_values(%i[new_customer inactive_customer all_customer]) }
  end
end
