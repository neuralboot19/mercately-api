require 'rails_helper'
require 'vcr'

RSpec.describe Facebook::Messages, vcr: true do
  subject(:messages_service) { described_class.new(facebook_retailer) }

  let(:facebook_retailer) { create(:facebook_retailer) }
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
      'timestamp': 1584712902747,
      'message': {
        'mid': 'm_KODXgRl3Z3jMnhcco43SmkOUElOLpk3ODw-8fGJl54fOaz40lxlvbAxoWPFIKA4cNc_0DXcN4qN9F6muDspxQA',
        'text': 'Buenos días'
      }
    }.with_indifferent_access
  end

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
end
