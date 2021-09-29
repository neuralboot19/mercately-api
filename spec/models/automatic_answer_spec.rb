require 'rails_helper'

RSpec.describe AutomaticAnswer, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:retailer) }
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:message_type) }
    it { is_expected.to validate_presence_of(:platform) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(%i[active inactive]) }
    it { is_expected.to define_enum_for(:message_type).with_values(%i[new_customer inactive_customer]) }
    it { is_expected.to define_enum_for(:platform).with_values(%i[whatsapp messenger instagram]) }
  end
end
