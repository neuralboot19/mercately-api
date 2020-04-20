require 'rails_helper'

RSpec.describe KarixWhatsappMessage, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:customer) }
  end

  describe '#substract_from_balance' do
    let!(:retailer) { create(:retailer) }
    let!(:retailer_user) { create(:retailer_user, retailer: retailer) }

    let!(:customer1) { create(:customer, retailer: retailer) }
    let!(:customer2) { create(:customer, retailer: retailer) }

    it 'will substract the retailer\'s ws_conversation_cost from the retailer balance if message_type is \'conversation\'' do
      former_retailer_balance = retailer.ws_balance
      create(:karix_whatsapp_message, retailer: retailer, customer: customer1, message_type: 'conversation')

      expect(retailer.reload.ws_balance).to eq(former_retailer_balance - retailer.ws_conversation_cost)
    end

    it 'will substract the retailer\'s ws_notification_cost from the retailer balance if message_type is \'notification\'' do
      former_retailer_balance = retailer.ws_balance

      create(:karix_whatsapp_message, retailer: retailer, customer: customer1, message_type: 'notification')
      expect(retailer.reload.ws_balance).to eq(former_retailer_balance - retailer.ws_notification_cost)
    end

    it 'expect not to set ws_next_notification_balance if ws_balance is > 1.5' do
      expect {
        create(:karix_whatsapp_message, retailer: retailer, customer: customer1)
      }.to_not change { retailer.ws_next_notification_balance }
    end

    it 'expect not to send a running out balance notification email if ws_balance is > 1.5' do
      expect {
        create(:karix_whatsapp_message, retailer: retailer, customer: customer1)
      }.to_not change { ActionMailer::Base.deliveries.size }
    end

    context 'if ws_balance <= to the current ws_next_notification_balance and it is > 0' do
      it 'will set ws_next_notification_balance down in -0.5 and send a running out balance notification email' do
        retailer.update_attributes(ws_balance: 1.4)

        expect {
          create(:karix_whatsapp_message, retailer: retailer, customer: customer1)
        }.to change { retailer.ws_next_notification_balance }.by(-0.5).and change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end
  end
end
