require 'rails_helper'

RSpec.describe FacebookMessage, type: :model do
  subject(:facebook_message) { create(:facebook_message, facebook_retailer: facebook_retailer) }

  let!(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let!(:facebook_retailer) { create(:facebook_retailer, retailer: retailer)}

  describe 'associations' do
    it { is_expected.to belong_to(:facebook_retailer) }
    it { is_expected.to belong_to(:customer) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:mid).allow_blank }
  end

  describe '#sent_by_retailer?' do
    context 'when sender and facebook retailer are not the same' do
      it 'does not set to true the sent_by_retailer attribute' do
        expect(facebook_message.send(:sent_by_retailer?)).to be_nil
      end
    end

    context 'when sender and facebook retailer are the same' do
      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, sender_uid: facebook_retailer.uid)
      end

      it 'sets to true the sent_by_retailer attribute' do
        expect(facebook_msg_sent.send(:sent_by_retailer?)).to be true
      end
    end
  end

  describe '#send_facebook_message' do
    let(:set_facebook_messages_service) { instance_double(Facebook::Messages) }
    let(:facebook_msg_sent) do
      create(:facebook_message, facebook_retailer: facebook_retailer, sent_from_mercately: true, text: 'Testing')
    end
    let(:facebook_file_sent) do
      create(:facebook_message, facebook_retailer: facebook_retailer, sent_from_mercately: true, file_data:
        '/tmp/file.pdf')
    end

    before do
      allow(set_facebook_messages_service).to receive(:send_message)
        .and_return({ message_id: Faker::Internet.uuid })
      allow(set_facebook_messages_service).to receive(:send_attachment)
        .and_return({ message_id: Faker::Internet.uuid })
      allow(Facebook::Messages).to receive(:new).with(facebook_retailer)
        .and_return(set_facebook_messages_service)
    end

    context 'when the message is sent from mercately' do
      context 'when the message is a text' do
        it 'calls the service to Facebok Message to send a text message' do
          expect(facebook_msg_sent.send(:send_facebook_message)).to be true
        end
      end

      context 'when the message contains an attachment' do
        it 'calls the service to Facebok Message to send an attachment message' do
          expect(facebook_file_sent.send(:send_facebook_message)).to be true
        end
      end
    end

    context 'when the message is not sent from mercately' do
      it 'does not call the Facebook Message service' do
        expect(facebook_message.send(:send_facebook_message)).to be_nil
      end
    end
  end
end
