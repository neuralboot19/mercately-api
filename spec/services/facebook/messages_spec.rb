require 'rails_helper'
require 'vcr'

RSpec.describe Facebook::Messages, vcr: true do
  subject(:messages_service) { described_class.new(facebook_retailer) }

  let!(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let!(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }

  let(:customer) { create(:customer, retailer: facebook_retailer.retailer, psid: message_data_save['sender']['id']) }
  let(:message_id) { 'm_5zQXER3IeTxCOXaHhNOhD0OUElOLpk3ODw-8fGJl54d3iTker4IqLmXsMnseIWB5jfv61RUW9yCCJdOcqegr2w' }

  let(:message_data_save) do
    {
      'sender': {
        'id': '2701618273252603'
      },
      'recipient': {
        'id': '101072371445783'
      },
      'timestamp': 158_471_290_274_7,
      'message': {
        'mid': 'm_KODXgRl3Z3jMnhcco43SmkOUElOLpk3ODw-8fGJl54fOaz40lxlvbAxoWPFIKA4cNc_0DXcN4qN9F6muDspxQA',
        'text': 'Buenos días'
      }
    }.with_indifferent_access
  end

  let(:response_message_read) { { 'recipient_id': '2701618273252603' } }

  describe '#save' do
    it 'saves a new FacebookMessage item in DB' do
      VCR.use_cassette('facebook/messages/save_message') do
        expect { messages_service.save(message_data_save) }.to change(FacebookMessage, :count).by(1)
      end
    end
  end

  describe '#import_delivered' do
    let(:facebook_message) { create(:facebook_message, facebook_retailer: facebook_retailer, mid: message_id) }

    it 'updates the message sent from Mercately' do
      expect(facebook_message.file_type).to be_nil

      VCR.use_cassette('facebook/messages/message_imported') do
        messages_service.import_delivered(facebook_message.mid, customer.psid)
        expect(facebook_message.reload.file_type).not_to be_nil
      end
    end
  end

  describe '#send_attachment' do
    it 'sends an attachment to Messenger' do
      file = fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg')

      VCR.use_cassette('facebook/messages/send_attachment') do
        response = messages_service.send_attachment(customer.psid, file.path, 'profile.jpg')
        expect(response['message_id']).not_to be_nil
      end
    end
  end

  describe '#mark_read' do
    before do
      create_list(:facebook_message, 2, facebook_retailer: facebook_retailer, customer:
        customer, sent_by_retailer: true)
    end

    it 'sets as read all the messages sent by the retailer' do
      expect(customer.facebook_messages.retailer_unread.count).to eq(2)
      messages_service.mark_read(customer.psid)
      expect(customer.facebook_messages.retailer_unread.count).to eq(0)
    end
  end

  describe '#send_read_action' do
    before do
      allow(Connection).to receive(:post_request)
        .and_return(response_message_read)
    end

    it 'sets as read the message sent by the customer in messenger' do
      expect(messages_service.send_read_action(customer.psid, 'mark_seen')).to eq(response_message_read)
    end
  end
end
