require 'rails_helper'

RSpec.describe AgentNotificationHelper, type: :helper do
  describe '#notify_agent' do
    let(:retailer) { create(:retailer) }
    let(:retailer_user) { create(:retailer_user, :agent, retailer: retailer) }
    let(:customer) { create(:customer) }
    let(:agent_customer) { create(:agent_customer, retailer_user: retailer_user, customer: customer) }

    context 'when chat type is not valid' do
      it 'raises an exception when chat type is not valid' do
        expect do
          AgentNotificationHelper.notify_agent(agent_customer, 'invalid_chat_type')
        end.to raise_error(StandardError, 'Chat type not valid for notification')
      end
    end
  end
end
