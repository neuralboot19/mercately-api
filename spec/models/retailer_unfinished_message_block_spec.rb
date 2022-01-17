require 'rails_helper'

RSpec.describe RetailerUnfinishedMessageBlock, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:customer) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:message_created_date) }
    it { is_expected.to validate_presence_of(:platform) }
    it { is_expected.to validate_presence_of(:message_date) }
    it { is_expected.to validate_presence_of(:statistics) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:platform).with_values(%i[whatsapp messenger instagram]) }
    it { is_expected.to define_enum_for(:statistics).with_values(%i[response_average new_conversations]) }
  end
end