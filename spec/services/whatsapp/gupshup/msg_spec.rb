require 'rails_helper'

RSpec.describe Whatsapp::Gupshup::V1::Outbound::Msg do
  let(:retailer) { create(:retailer, :gupshup_integrated) }
  let(:customer) { create(:customer, retailer: retailer) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let(:net_response) { Net::HTTPOK.new(1.0, '200', 'OK') }

  let(:audio_params) do
    {
      file_data: fixture_file_upload(Rails.root + 'spec/fixtures/notification_tune.mp3', 'audio/mp3'),
      type: 'audio'
    }
  end

  let(:cloudinary_audio_response) do
    {
      'asset_id': 'c7fa2c0720915a5f998d7533ccb1b8d7',
      'public_id': 'mubnkttmuxmbexcqqucz',
      'version': 1600269975,
      'version_id': 'bc1914c017e198664eb695fbc5fc9eb4',
      'signature': '7e017bb966eb6f9d9d65a68cc635d8c82bbe910a',
      'width': 0,
      'height': 0,
      'format': 'webm',
      'resource_type': 'video',
      'created_at': '2020-09-16T15:26:15Z',
      'tags': [],
      'pages': 0,
      'bytes': 31121,
      'type': 'upload',
      'etag': '9af3be16f4811fa2eebb1f202de5dec8',
      'placeholder': false,
      'url': 'http://res.cloudinary.com/dhhrdm74a/video/upload/v1600269975/mubnkttmuxmbexcqqucz.webm',
      'secure_url': 'https://res.cloudinary.com/dhhrdm74a/video/upload/v1600269975/mubnkttmuxmbexcqqucz.webm',
      'audio': {
        'codec': 'opus',
        'frequency': 48000,
        'channels': 1,
        'channel_layout': 'mono'
      },
      'video': {},
      'is_audio': true,
      'duration': 5.04,
      'original_filename': 'blob'
    }.with_indifferent_access
  end

  let(:ok_body_response) do
    {
      'status': 'submitted',
      'messageId': 'c011a9c0-051d-4e01-a130-7b12903decb8'
    }.to_json
  end

  describe '#send_message' do
    context 'when the message type is file' do
      context 'when the file is an audio' do
        it 'uploads the audio to Cloudinary and prepares the message body to send it to GupShup' do
          allow(Cloudinary::Uploader).to receive(:upload).and_return(cloudinary_audio_response)
          allow_any_instance_of(Whatsapp::Gupshup::V1::Base).to receive(:post).and_return(net_response)
          allow_any_instance_of(Net::HTTPOK).to receive(:read_body).and_return(ok_body_response)

          expect {
            @resp = described_class.new(retailer, customer).send_message(type: 'file', params:
              audio_params, retailer_user: retailer_user)
          }.to change(GupshupWhatsappMessage, :count).by(1)

          gs_message = GupshupWhatsappMessage.find_by_gupshup_message_id(@resp[:body]['messageId'])
          expect(gs_message.message_payload['url']).to eq(cloudinary_audio_response['secure_url']
            .gsub('.webm', '.aac'))
        end
      end
    end
  end
end
