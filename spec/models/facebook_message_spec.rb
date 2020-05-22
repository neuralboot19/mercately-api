require 'rails_helper'

RSpec.describe FacebookMessage, type: :model do
  subject(:facebook_message) { create(:facebook_message, facebook_retailer: facebook_retailer) }

  let!(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let!(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }

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
        .and_return(message_id: Faker::Internet.uuid)
      allow(set_facebook_messages_service).to receive(:send_attachment)
        .and_return(message_id: Faker::Internet.uuid)
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

  describe '#send_welcome_message' do
    let(:set_facebook_messages_service) { instance_double(Facebook::Messages) }

    before do
      allow(set_facebook_messages_service).to receive(:send_message)
        .and_return('Sent')
      allow(Facebook::Messages).to receive(:new).with(facebook_retailer)
        .and_return(set_facebook_messages_service)
    end

    context 'when the retailer does not have an active welcome message configured' do
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_welcome_message)).to be nil
      end
    end

    context 'when the customer does not text for the first time' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :messenger, retailer: facebook_retailer.retailer) }
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let!(:first_facebook_message) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, text: 'Test')
      end

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_welcome_message)).to be nil
      end
    end

    context 'when the message is sent from the retailer' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :messenger, retailer: facebook_retailer.retailer) }
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          true, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_welcome_message)).to be nil
      end
    end

    context 'when all conditions are present' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :messenger, retailer: facebook_retailer.retailer) }
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'sends the message' do
        expect { facebook_msg_sent.send(:send_welcome_message) }.to change(FacebookMessage, :count).by(2)
      end
    end
  end

  describe '#send_inactive_message' do
    let(:set_facebook_messages_service) { instance_double(Facebook::Messages) }

    before do
      allow(set_facebook_messages_service).to receive(:send_message)
        .and_return('Sent')
      allow(Facebook::Messages).to receive(:new).with(facebook_retailer)
        .and_return(set_facebook_messages_service)
    end

    context 'when the retailer does not have an inactive message configured' do
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let!(:first_facebook_message) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Test')
      end

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the customer does not have a prior message sent' do
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let!(:automatic_answer) do
        create(:automatic_answer, :inactive, :messenger, retailer: facebook_retailer.retailer)
      end

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the message is sent from the retailer' do
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let!(:automatic_answer) do
        create(:automatic_answer, :inactive, :messenger, retailer: facebook_retailer.retailer)
      end

      let!(:first_facebook_message) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Test')
      end

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          true, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the created time of the prior message is not passed yet' do
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let!(:automatic_answer) do
        create(:automatic_answer, :inactive, :messenger, retailer: facebook_retailer.retailer)
      end

      let!(:first_facebook_message) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Test', created_at: Time.now - 11.hours)
      end

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_inactive_message)).to be nil
      end
    end

    context 'when all conditions are present' do
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let!(:automatic_answer) do
        create(:automatic_answer, :inactive, :messenger, retailer: facebook_retailer.retailer)
      end

      let!(:first_facebook_message) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Test', created_at: Time.now - 13.hours)
      end

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'sends the message' do
        expect { facebook_msg_sent.send(:send_inactive_message) }.to change(FacebookMessage, :count).by(3)
      end
    end
  end
end
