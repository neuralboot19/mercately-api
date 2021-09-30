require 'rails_helper'

RSpec.describe WhatsappLog, type: :model do
  subject(:whatsapp_log) { build(:whatsapp_log) }

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:gupshup_whatsapp_message).optional }
  end
end
