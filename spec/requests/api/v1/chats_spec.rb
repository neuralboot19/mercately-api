require 'rails_helper'

RSpec.describe 'Api::V1::ChatsController', type: :request do
  let(:retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }

  before do
    allow(Whatsapp::Gupshup::V1::Helpers::Messages).to receive(:new).and_return(true)
    allow_any_instance_of(Whatsapp::Gupshup::V1::Helpers::Messages).to receive(:notify_customer_update!)
      .and_return(true)
    allow(FacebookNotificationHelper).to receive(:broadcast_data).and_return(true)
    allow(KarixNotificationHelper).to receive(:broadcast_data).and_return(true)

    sign_in retailer_user
  end

  describe 'PUT #change_chat_status' do
    context 'when changing to resolved status' do
      context 'when the chat is on open_chat status' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'open_chat') }

        it 'sets the chat as resolved' do
          expect {
            put api_v1_change_chat_status_path, params: {
              chat: {
                customer_id: customer.id,
                status_chat: 'resolved'
              }
            }
          }.to change(ChatHistory, :count).by(1)

          expect(response.code).to eq('200')
          expect(customer.reload.status_chat).to eq('resolved')

          chat_history = ChatHistory.last
          expect(chat_history.chat_status).to eq('chat_resolved')
          expect(chat_history.action).to eq('change_to')
          expect(chat_history.retailer_user_id).to eq(retailer_user.id)
        end
      end

      context 'when the chat is on in_process status' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'in_process') }

        it 'sets the chat as resolved' do
          expect {
            put api_v1_change_chat_status_path, params: {
              chat: {
                customer_id: customer.id,
                status_chat: 'resolved'
              }
            }
          }.to change(ChatHistory, :count).by(1)

          expect(response.code).to eq('200')
          expect(customer.reload.status_chat).to eq('resolved')

          chat_history = ChatHistory.last
          expect(chat_history.chat_status).to eq('chat_resolved')
          expect(chat_history.action).to eq('change_to')
          expect(chat_history.retailer_user_id).to eq(retailer_user.id)
        end
      end

      context 'when the chat is not on open_chat and in_process status' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'new_chat') }

        it 'does not set the chat as resolved' do
          expect {
            put api_v1_change_chat_status_path, params: {
              chat: {
                customer_id: customer.id,
                status_chat: 'resolved'
              }
            }
          }.to change(ChatHistory, :count).by(0)

          body = JSON.parse(response.body)
          expect(response.code).to eq('422')
          expect(body['message']).to eq('No fue posible cambiar el status del chat')
        end
      end
    end

    context 'when changing to in_process status' do
      context 'when the chat is on resolved status' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'resolved') }

        it 'sets the chat as in_process' do
          expect {
            put api_v1_change_chat_status_path, params: {
              chat: {
                customer_id: customer.id,
                status_chat: 'in_process'
              }
            }
          }.to change(ChatHistory, :count).by(1)

          expect(response.code).to eq('200')
          expect(customer.reload.status_chat).to eq('in_process')

          chat_history = ChatHistory.last
          expect(chat_history.chat_status).to eq('chat_in_process')
          expect(chat_history.action).to eq('change_to')
          expect(chat_history.retailer_user_id).to eq(retailer_user.id)
        end
      end

      context 'when the chat is not on resolved status' do
        let(:customer) { create(:customer, retailer: retailer, status_chat: 'open_chat') }

        it 'does not set the chat as in_process' do
          expect {
            put api_v1_change_chat_status_path, params: {
              chat: {
                customer_id: customer.id
              }
            }
          }.to change(ChatHistory, :count).by(0)

          body = JSON.parse(response.body)
          expect(response.code).to eq('422')
          expect(body['message']).to eq('No fue posible cambiar el status del chat')
        end
      end
    end
  end
end
