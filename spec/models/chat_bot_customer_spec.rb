require 'rails_helper'

RSpec.describe ChatBotCustomer, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:chat_bot) }
  end

  describe 'scopes' do
    let(:chat_bot_customer_out) { create(:chat_bot_customer, created_at: Time.now - 10.hours) }
    let(:chat_bot_customer_in) { create(:chat_bot_customer, created_at: Time.now - 8.hours) }
    let(:chat_bot_customer_out2) { create(:chat_bot_customer, created_at: Time.now - 12.hours) }
    let(:chat_bot_customer_in2) { create(:chat_bot_customer, created_at: Time.now - 1.hours) }

    it 'returns the records created in a given range of time' do
      chat_bot_customer_out
      chat_bot_customer_in
      chat_bot_customer_out2
      chat_bot_customer_in2

      expect(described_class.range_between(Time.now - 9.hours, Time.now).count).to eq(2)
    end
  end
end
