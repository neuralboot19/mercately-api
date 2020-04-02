require 'rails_helper'

RSpec.describe CustomerHelper, type: :helper do
  describe '#customer_ordering_options' do
    it 'returns a list of options to filter' do
      expect(helper.customer_ordering_options.size).to eq(13)
    end
  end

  describe '#can_send_whatsapp_notification?' do
    let(:retailer) { create(:retailer) }
    let(:retailer_user_admin) { create(:retailer_user, :admin, retailer: retailer) }
    let(:retailer_user_agent) { create(:retailer_user, :agent, retailer: retailer) }
    let(:retailer_user_with_customer) { create(:retailer_user, :agent, retailer: retailer) }
    let(:customer) { create(:customer) }

    let(:agent_customer) do
      create(:agent_customer, retailer_user: retailer_user_with_customer, customer: customer)
    end

    context 'when the retailer does not have whatsapp enabled' do
      it 'returns false' do
        agent_customer.customer.phone = '+593123456789'
        expect(helper.can_send_whatsapp_notification?(retailer_user_admin,
          agent_customer.customer)).to be false
      end
    end

    context 'when the agent is an admin' do
      context 'when the customer does not have phone number' do
        it 'returns false' do
          retailer_user_admin.retailer.whats_app_enabled = true
          agent_customer.customer.phone = nil

          expect(helper.can_send_whatsapp_notification?(retailer_user_admin,
            agent_customer.customer)).to be false
        end
      end

      context 'when the customer have phone number but not in international format' do
        it 'returns false' do
          retailer_user_admin.retailer.whats_app_enabled = true
          agent_customer.customer.phone = '0123456789'

          expect(helper.can_send_whatsapp_notification?(retailer_user_admin,
            agent_customer.customer)).to be false
        end
      end

      context 'when the retailer has whatsapp enabled and customers phone is well formatted' do
        it 'returns true' do
          agent_customer.customer.phone = '+593123456789'
          retailer_user_admin.retailer.whats_app_enabled = true

          expect(helper.can_send_whatsapp_notification?(retailer_user_admin,
            agent_customer.customer)).to be true
        end
      end
    end

    context 'when the agent is not an admin but it has the customer assigned' do
      context 'when the customer does not have phone number' do
        it 'returns false' do
          retailer_user_with_customer.retailer.whats_app_enabled = true
          agent_customer.customer.phone = nil

          expect(helper.can_send_whatsapp_notification?(retailer_user_with_customer,
            agent_customer.customer)).to be false
        end
      end

      context 'when the customer have phone number but not in international format' do
        it 'returns false' do
          retailer_user_with_customer.retailer.whats_app_enabled = true
          agent_customer.customer.phone = '0123456789'

          expect(helper.can_send_whatsapp_notification?(retailer_user_with_customer,
            agent_customer.customer)).to be false
        end
      end

      context 'when the retailer has whatsapp enabled and customers phone is well formatted' do
        it 'returns true' do
          agent_customer.customer.phone = '+593123456789'
          retailer_user_with_customer.retailer.whats_app_enabled = true

          expect(helper.can_send_whatsapp_notification?(retailer_user_with_customer,
            agent_customer.customer)).to be true
        end
      end
    end

    context 'when the agent is not an admin and it does not have the customer assigned' do
      it 'returns false' do
        expect(helper.can_send_whatsapp_notification?(retailer_user_agent, customer)).to be false
      end
    end
  end
end
