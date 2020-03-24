require 'rails_helper'

RSpec.describe Whatsapp::Karix::Api do
  let(:retailer) { create(:retailer) }
  let(:customer) { create(:customer, retailer: retailer) }

  let(:params) do
    {
      file_data: fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg')
    }
  end

  let(:raw_params) do
    {
      file_data: fixture_file_upload(Rails.root + 'spec/fixtures/Prueba-de-word.doc', 'application/msword')
    }
  end

  let(:cloudinary_image_response) do
    {
      'public_id': 'udbdbn7nv4xxupagiaxc',
      'version': 1585073676,
      'signature': '5d01c78a3b9e3ecd7563ce0cfd72bb48a256ee64',
      'width': 236,
      'height': 203,
      'format': 'jpeg',
      'resource_type': 'image',
      'created_at': '2020-03-24T18:14:36Z',
      'tags': [],
      'bytes': 17804,
      'type': 'upload',
      'etag': 'ae455f6806cb00961ca947e120277fb3',
      'placeholder': false,
      'url': 'http://res.cloudinary.com/dhhrdm74a/image/upload/v1585073676/udbdbn7nv4xxupagiaxc.jpg',
      'secure_url': 'https://res.cloudinary.com/dhhrdm74a/image/upload/v1585073676/udbdbn7nv4xxupagiaxc.jpg',
      'original_filename': 'shop_(1)'
    }.with_indifferent_access
  end

  let(:cloudinary_raw_response) do
    {
      'public_id': 'muaboemegezm5wygcv4x.doc',
      'version': 1585072510,
      'signature': '35b0a4499de3e9a17ad84453ad9e97148170d3ce',
      'resource_type': 'raw',
      'created_at': '2020-03-24T17:55:10Z',
      'tags': [],
      'bytes': 15360,
      'type': 'upload',
      'etag': '20b397a1193d6c3e62b7908162359234',
      'placeholder': false,
      'url': 'http://res.cloudinary.com/dhhrdm74a/raw/upload/v1585072510/muaboemegezm5wygcv4x.doc',
      'secure_url': 'https://res.cloudinary.com/dhhrdm74a/raw/upload/v1585072510/muaboemegezm5wygcv4x.doc',
      'original_filename': 'Prueba de word'
    }.with_indifferent_access
  end

  describe '#prepare_whatsapp_message_file' do
    context 'when the file is an image' do
      it 'uploads the file to Cloudinary and prepares the message body to send the file to Karix' do
        allow(Cloudinary::Uploader).to receive(:upload).and_return(cloudinary_image_response)
        resp = JSON.parse(described_class.new.prepare_whatsapp_message_file(retailer, customer, params))
          .with_indifferent_access

        expect(resp[:content][:media][:url]).to eq(cloudinary_image_response[:secure_url])
      end
    end

    context 'when the file is Word or PDF' do
      it 'uploads the file to Cloudinary and prepares the message body to send the file to Karix' do
        allow(Cloudinary::Uploader).to receive(:upload).and_return(cloudinary_raw_response)
        resp = JSON.parse(described_class.new.prepare_whatsapp_message_file(retailer, customer, raw_params))
          .with_indifferent_access

        expect(resp[:content][:media][:url]).to eq(cloudinary_raw_response[:secure_url])
      end
    end
  end
end
