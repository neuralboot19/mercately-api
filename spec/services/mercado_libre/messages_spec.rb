require 'rails_helper'
require 'vcr'

RSpec.describe MercadoLibre::Messages, vcr: true do
  subject(:messages_service) { described_class.new(retailer) }

  let(:retailer) { meli_retailer.retailer }
  let(:meli_retailer) { create(:meli_retailer) }
  let(:meli_customer) { create(:meli_customer, nickname: 'TESTHSWDBJHG') }
  let(:customer) { create(:customer, :from_ml, retailer: retailer, meli_customer: meli_customer) }
  let!(:retailer_user) { create(:retailer_user, retailer: meli_retailer.retailer) }
  let!(:order) { create(:order, meli_order_id: '2194381783', customer: customer) }

  describe '#import' do
    context 'when the message comes from the customer' do
      context 'when the customer is the same of the order' do
        it 'saves the message' do
          VCR.use_cassette('messages/message_readed') do
            expect { messages_service.import('a1f4ddcaa5874871b00b3baaa02cf245') }.to change(Message, :count).by(1)
          end
        end
      end

      context 'when the customer is not the same of the order' do
        let(:customer2) { create(:customer, retailer: retailer) }

        it 'does not save the message' do
          order.update(customer: customer2)
          VCR.use_cassette('messages/message_readed') do
            expect { messages_service.import('a1f4ddcaa5874871b00b3baaa02cf245') }.to change(Message, :count).by(0)
          end
        end
      end
    end

    context 'when the message is sent from ML' do
      context 'when te message comes from the retailer' do
        context 'when the retailer is the same of the customer of the order' do
          it 'saves the message' do
            VCR.use_cassette('messages/message_from_retailer') do
              expect { messages_service.import('935039e5a90f4f428b7051931af04a0b') }.to change(Message, :count).by(1)
            end
          end
        end

        context 'when the retailer is not the same of the customer of the order' do
          let(:retailer2) { create(:retailer) }
          let(:customer2) { create(:customer, retailer: retailer2) }

          it 'does not save the message' do
            order.update(customer: customer2)
            VCR.use_cassette('messages/message_from_retailer') do
              expect { messages_service.import('935039e5a90f4f428b7051931af04a0b') }.to change(Message, :count).by(0)
            end
          end
        end
      end
    end
  end

  describe '#answer_message' do
    let(:message) { create(:message, order: order, customer: customer) }

    before do
      stub_const('Response', Struct.new(:status, :body))
      response = Response.new(201, '{"status": "success", "message": "My answer message"}')
      allow(Connection).to receive(:post_request)
        .with(anything, anything).and_return(response)
    end

    it 'sends a message for that order in ML' do
      response = messages_service.answer_message(message)
      expect(response).to have_key('message')
    end
  end
end
