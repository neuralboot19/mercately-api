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

  describe 'GET #notifications_list' do
    before do
      create_list(:agent_notification, 10, :whatsapp, retailer_user: retailer_user, customer: customer)
      create_list(:agent_notification, 12, :messenger, retailer_user: retailer_user, customer: customer)
      create_list(:agent_notification, 5, :whatsapp, retailer_user: create(:retailer_user, retailer: retailer), customer: customer)
    end

    context 'when notifications count is less than 25' do
      it 'returns first page' do
        get '/api/v1/notifications_list'
        expect(response.code).to eq('200')
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['notifications']['data'].length).to eq(22)
        expect(parsed_response['total']).to eq(1)
      end

      it 'returns valid serialized values' do
        get '/api/v1/notifications_list'
        expect(response.code).to eq('200')
        expect(response.body).to eq({
          notifications:
            AgentNotificationSerializer.new(retailer_user.agent_notifications.order(created_at: :desc).page(1)),
          total: 1
        }.to_json)
      end
    end

    context 'when notifications count is less than 25' do
      before do
        create_list(:agent_notification, 10, :whatsapp, retailer_user: retailer_user, customer: customer)
      end

      it 'returns following pages' do
        get '/api/v1/notifications_list',
            params: {
              page: '2'
            }
        expect(response.code).to eq('200')
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['notifications']['data'].length).to eq(7)
        expect(parsed_response['total']).to eq(2)
      end
    end

    context 'when serializer fails to load a resource' do
      before do
        create(:agent_notification, retailer_user: retailer_user, customer: customer)
      end

      it 'returns following pages' do
        get '/api/v1/notifications_list',
            params: {
              page: '1'
            }
        parsed_response_body = JSON.parse(response.body)
        expect(response.code).to eq('500')
        expect(parsed_response_body['message']).to eq('Chat type not valid for notification')
      end
    end
  end
end
