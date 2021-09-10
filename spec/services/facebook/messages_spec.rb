require 'rails_helper'
require 'vcr'

RSpec.describe Facebook::Messages, vcr: true do
  subject(:messages_service) { described_class.new(facebook_retailer) }

  let!(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let!(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }

  let!(:customer) do
    create(:customer, :messenger, retailer: facebook_retailer.retailer, psid: message_data_save['sender']['id'])
  end

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

  let(:image_response) do
    {
      'sender': {
        'id': '2701618273252603'
      },
      'recipient': {
        'id': '101072371445783'
      },
      'timestamp': 158_471_290_274_7,
      'message': {
        'mid': 'm_nSu6JMgG3WAPSk8VnAZGkUOUElOLpk3ODw-8fGJl54ceV2t3gs0-kBbFNPIKzcmYG1Fs3Nu5TUK0jlwdfBSp-g',
        'attachments': [
          {
            'type': 'image',
            'payload': {
              'url': 'https://scontent.xx.fbcdn.net/v/t1.15752-9/90441567_200152011413011_5011659860094222336_n.png?' \
              '_nc_cat=104&_nc_sid=b96e70&_nc_ohc=eUTiF2BmlOIAX-3TbsS&_nc_ad=z-m&_nc_cid=0&_nc_ht=' \
              'scontent.xx&oh=593765a0372736abb1a05f7964b4221c&oe=5EFBA946'
            }
          }
        ]
      }
    }.with_indifferent_access
  end

  let(:location_response) do
    {
      'sender': {
        'id': '2701618273252603'
      },
      'recipient': {
        'id': '101072371445783'
      },
      'timestamp': 158_471_290_274_7,
      'message': {
        'mid': 'm_RLWdGrKwoIB9ZZwkROgzaEOUElOLpk3ODw-8fGJl54c6pGmhwTRWjyilAy5GIyEX9VL9p3xOjfMgm8RC-gS23g',
        'attachments': [
          {
            'title': 'Maracay',
            'url': 'https://l.facebook.com/l.php?u=https%3A%2F%2Fwww.bing.com%2Fmaps%2Fdefault.' \
              'aspx%3Fv%3D2%26pc%3DFACEBK%26mid%3D8100%26where1%3DMaracay%26FORM%3DFBKPL1%26mkt%3Des-MX&h=' \
              'AT3jp3ZMvmgmJPdyHSlEEmkNzpQTYwU65ByZ6jRX8j99cGpYjkFuvk3BQItwHxuMk0QzmnpT0iyqP-TngYz9NofrlbHerzu' \
              '89UurEeBOjDyZapFbknMBLQonuUI-CBvgnBN4lYkfYylE&s=1',
            'type': 'location',
            'payload': {
              'coordinates': {
                'lat': 10.2399,
                'long': -67.6036
              }
            }
          }
        ]
      }
    }.with_indifferent_access
  end

  let(:send_attachment_response) do
    {
      'recipient_id': '1008372609250235',
      'message_id': 'm_AG5Hz2Uq7tuwNEhXfYYKj8mJEM_QPpz5jdCK48PnKAjSdjfipqxqMvK8ma6AC8fplwlqLP_5cgXIbu7I3rBN0P'
    }
  end

  let(:get_started_button_response) do
    {
      'sender': {
        'id': '2701618273252603'
      },
      'recipient': {
        'id': '101072371445783'
      },
      'timestamp': 1615219411827,
      'postback': {
        'title': 'Get Started',
        'payload': 'Iniciar chat'
      }
    }.with_indifferent_access
  end

  describe '#save' do
    let(:customers_service) { Facebook::Customers.new(facebook_retailer) }

    before do
      allow(Facebook::Customers).to receive(:new).and_return(customers_service)
      allow_any_instance_of(Facebook::Customers).to receive(:import).and_return(customer)
    end

    context 'when is a text message' do
      it 'saves the text' do
        expect { messages_service.save(message_data_save) }.to change(FacebookMessage, :count).by(1)
        expect(FacebookMessage.last.text).to eq('Buenos días')
      end
    end

    context 'when is a location message' do
      it 'saves the location' do
        expect { messages_service.save(location_response) }.to change(FacebookMessage, :count).by(1)
        expect(FacebookMessage.last.file_type).to eq('location')
      end
    end

    context 'when is any other type of message' do
      it 'saves the message' do
        expect { messages_service.save(image_response) }.to change(FacebookMessage, :count).by(1)
        expect(FacebookMessage.last.file_type).to eq('image')
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
    context 'when file_data is present' do
      it 'sends an attachment to Messenger' do
        file = fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg')

        VCR.use_cassette('facebook/messages/send_attachment') do
          response = messages_service.send_attachment(customer.psid, file.path, 'profile.jpg')
          expect(response['message_id']).not_to be_nil
        end
      end
    end

    context 'when url is present' do
      before do
        allow(Connection).to receive(:post_form_request).and_return(double("response", status: 200, body:
          send_attachment_response.to_json))
      end

      it 'sends an attachment to Messenger' do
        response = messages_service.send_attachment(customer.psid, nil, nil, 'https://www.images.com/image.jpg',
          'image')

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

  describe '#save_postback_interaction' do
    let(:customers_service) { Facebook::Customers.new(facebook_retailer) }

    before do
      allow(Facebook::Customers).to receive(:new).and_return(customers_service)
      allow_any_instance_of(Facebook::Customers).to receive(:import).and_return(customer)
    end

    it 'saves get started button payload as a text message' do
      expect do
        messages_service.save_postback_interaction(get_started_button_response)
      end.to change(FacebookMessage, :count).by(1)

      expect(FacebookMessage.last.text).to eq('Iniciar chat')
    end
  end
end
