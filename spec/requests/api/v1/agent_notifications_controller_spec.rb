require 'rails_helper'

RSpec.describe 'Api::V1::AgentNotificationsController', type: :request do
  let(:retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let(:customer) { create(:customer, retailer: retailer) }
  let(:agent_notification) { create(:agent_notification, retailer_user: retailer_user, customer: customer) }

  before do
    sign_in retailer_user
  end

  describe 'PATCH #mark_notification_as_read' do
    context 'when notification is found' do
      it 'successfully, a 200 Ok will be responded' do
        patch '/api/v1/mark_notification_as_read',
              params: {
                agent_notification: {
                  id: agent_notification.id
                }
              }
        expect(response.code).to eq('200')
        expect(AgentNotification.find(agent_notification.id).status).to eq('read')
      end
    end

    context 'when notification is not found' do
      it 'a 400 Ok will be responded' do
        patch '/api/v1/mark_notification_as_read',
          params: {
            agent_notification: {
              id: agent_notification.id + 1
            }
          }
        expect(response.code).to eq('400')
        expect(AgentNotification.find(agent_notification.id).status).to eq('unread')
      end
    end

    context 'when notification status could not be updated' do
      it 'a 400 Ok will be responded' do
        allow_any_instance_of(AgentNotification).to receive(:read!).and_raise(StandardError)
        patch '/api/v1/mark_notification_as_read',
              params: {
                agent_notification: {
                  id: agent_notification.id
                }
              }
        expect(response.code).to eq('400')
        expect(AgentNotification.find(agent_notification.id).status).to eq('unread')
      end
    end
  end

  describe 'PATCH #mark_by_customer_as_read' do
    describe 'when notification type is whatsapp' do
      context 'when notifications are found' do
        before do
          create(:agent_notification, :whatsapp, retailer_user: retailer_user, customer: customer)
          create(:agent_notification, :whatsapp, retailer_user: retailer_user, customer: customer)
          create(:agent_notification, :messenger, retailer_user: retailer_user, customer: customer)
        end

        it 'successfully, a 200 Ok will be responded' do
          patch '/api/v1/mark_by_customer_as_read',
              params: {
                agent_notification: {
                  customer_id: customer.id,
                  notification_type: 'whatsapp'
                }
              }
          expect(response.code).to eq('200')
          expect(AgentNotification.unread.count).to eq(1)
          expect(AgentNotification.read.count).to eq(2)
        end
      end

      context 'when error is thrown found' do
        it 'a 400 Ok will be responded' do
          allow(AgentNotification).to receive(:mark_by_customer_as_read!).and_raise(StandardError)
          patch '/api/v1/mark_by_customer_as_read',
                params: {
                  agent_notification: {
                    customer_id: customer.id,
                    notification_type: 'whatsapp'
                  }
                }
          expect(response.code).to eq('400')
        end
      end
    end

    describe 'when notification type is whatsapp' do
      context 'when notifications are found' do
        before do
          create(:agent_notification, :whatsapp, retailer_user: retailer_user, customer: customer)
          create(:agent_notification, :whatsapp, retailer_user: retailer_user, customer: customer)
          create(:agent_notification, :messenger, retailer_user: retailer_user, customer: customer)
        end

        it 'successfully, a 200 Ok will be responded' do
          patch '/api/v1/mark_by_customer_as_read',
                params: {
                  agent_notification: {
                    customer_id: customer.id,
                    notification_type: 'whatsapp'
                  }
                }
          expect(response.code).to eq('200')
          expect(AgentNotification.unread.count).to eq(1)
          expect(AgentNotification.read.count).to eq(2)
        end
      end

      context 'when error is thrown found' do
        it 'a 400 Ok will be responded' do
          allow(AgentNotification).to receive(:mark_by_customer_as_read!).and_raise(StandardError)
          patch '/api/v1/mark_by_customer_as_read',
                params: {
                  agent_notification: {
                    customer_id: customer.id,
                    notification_type: 'whatsapp'
                  }
                }
          expect(response.code).to eq('400')
        end
      end
    end

    describe 'when notification type is messenger' do
      context 'when notifications are found' do
        before do
          create(:agent_notification, :messenger, retailer_user: retailer_user, customer: customer)
          create(:agent_notification, :whatsapp, retailer_user: retailer_user, customer: customer)
          create(:agent_notification, :messenger, retailer_user: retailer_user, customer: customer)
        end

        it 'successfully, a 200 Ok will be responded' do
          patch '/api/v1/mark_by_customer_as_read',
                params: {
                  agent_notification: {
                    customer_id: customer.id,
                    notification_type: 'messenger'
                  }
                }
          expect(response.code).to eq('200')
          expect(AgentNotification.unread.count).to eq(1)
          expect(AgentNotification.read.count).to eq(2)
        end
      end

      context 'when error is thrown found' do
        it 'a 400 Ok will be responded' do
          allow(AgentNotification).to receive(:mark_by_customer_as_read!).and_raise(StandardError)
          patch '/api/v1/mark_by_customer_as_read',
                params: {
                  agent_notification: {
                    customer_id: customer.id,
                    notification_type: 'messenger'
                  }
                }
          expect(response.code).to eq('400')
        end
      end
    end
  end
end
