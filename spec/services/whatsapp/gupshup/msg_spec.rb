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

  let(:audio_url_params) do
    {
      url: 'https://res.cloudinary.com/dhhrdm74a/video/upload/v1600269975/mubnkttmuxmbexcqqucz.mp4',
      type: 'audio'
    }
  end

  let(:pdf_url_params) do
    {
      url: 'https://res.cloudinary.com/dhhrdm74a/image/upload/v1600786470/7dgvVqKauCLTLQtWvWy1yEDb.pdf',
      type: 'file',
      content_type: 'application/pdf',
      file_name: 'Test Spec'
    }
  end

  let(:image_url_params_with_content_type) do
    {
      url: 'https://res.cloudinary.com/dhhrdm74a/image/upload/v1600715681/cEp879PjfNVgMaZ86vN9vAxD.png',
      type: 'file',
      content_type: 'image/png'
    }
  end

  let(:image_url_params) do
    {
      url: 'https://res.cloudinary.com/dhhrdm74a/image/upload/v1600715681/cEp879PjfNVgMaZ86vN9vAxD.png',
      type: 'file'
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

  let(:template_text_params) do
    {
      template: true,
      message: 'Your Test number 12345 has been updated.',
      customer_id: customer.id,
      type: 'text'
    }
  end

  let(:template_id_params) do
    {
      template: true,
      message: 'Your OTP for Test is abc. This is valid for Today.',
      customer_id: customer.id,
      type: 'text',
      template_params: ['Test', 'abc', 'Today'],
      gupshup_template_id: '997dd550-c8d8-4bf7-ad98-a5ac4844a1ed'
    }
  end

  describe '#send_message' do
    context 'when the message type is file' do
      context 'when the file is a PDF' do
        context 'when the PDF is sent as an URL' do
          context 'when the content_type is passed in parameters' do
            it 'prepares the message body to send it to GupShup' do
              allow_any_instance_of(Whatsapp::Gupshup::V1::Base).to receive(:post).and_return(net_response)
              allow_any_instance_of(Net::HTTPOK).to receive(:read_body).and_return(ok_body_response)

              expect {
                @resp = described_class.new(retailer, customer).send_message(type: 'file', params:
                  pdf_url_params, retailer_user: retailer_user)
              }.to change(GupshupWhatsappMessage, :count).by(1)

              gs_message = GupshupWhatsappMessage.find_by_gupshup_message_id(@resp[:body]['messageId'])
              expect(gs_message.message_payload['url']).to eq(pdf_url_params[:url])
            end
          end
        end
      end

      context 'when the file is an image' do
        context 'when the image is sent as an URL' do
          context 'when the content_type is passed in parameters' do
            it 'prepares the message body to send it to GupShup' do
              allow_any_instance_of(Whatsapp::Gupshup::V1::Base).to receive(:post).and_return(net_response)
              allow_any_instance_of(Net::HTTPOK).to receive(:read_body).and_return(ok_body_response)

              expect {
                @resp = described_class.new(retailer, customer).send_message(type: 'file', params:
                  image_url_params_with_content_type, retailer_user: retailer_user)
              }.to change(GupshupWhatsappMessage, :count).by(1)

              gs_message = GupshupWhatsappMessage.find_by_gupshup_message_id(@resp[:body]['messageId'])
              expect(gs_message.message_payload['originalUrl']).to eq(image_url_params_with_content_type[:url])
            end
          end

          context 'when the content_type is not passed in parameters' do
            it 'prepares the message body to send it to GupShup' do
              allow_any_instance_of(Whatsapp::Gupshup::V1::Base).to receive(:post).and_return(net_response)
              allow_any_instance_of(Net::HTTPOK).to receive(:read_body).and_return(ok_body_response)

              expect {
                @resp = described_class.new(retailer, customer).send_message(type: 'file', params:
                  image_url_params, retailer_user: retailer_user)
              }.to change(GupshupWhatsappMessage, :count).by(1)

              gs_message = GupshupWhatsappMessage.find_by_gupshup_message_id(@resp[:body]['messageId'])
              expect(gs_message.message_payload['originalUrl']).to eq(image_url_params[:url])
            end
          end
        end
      end

      context 'when the file is an audio' do
        context 'when the audio is sent as a file object' do
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

        context 'when the audio is sent as an URL' do
          it 'prepares the message body to send it to GupShup' do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Base).to receive(:post).and_return(net_response)
            allow_any_instance_of(Net::HTTPOK).to receive(:read_body).and_return(ok_body_response)

            expect {
              @resp = described_class.new(retailer, customer).send_message(type: 'file', params:
                audio_url_params, retailer_user: retailer_user)
            }.to change(GupshupWhatsappMessage, :count).by(1)

            gs_message = GupshupWhatsappMessage.find_by_gupshup_message_id(@resp[:body]['messageId'])
            expect(gs_message.message_payload['url']).to eq(audio_url_params[:url].gsub('.mp4', '.aac'))
          end
        end
      end
    end

    context 'when the message type is text' do
      context 'when it is a template' do
        context 'when it is sent through template text' do
          it 'sends the text of the template' do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Base).to receive(:post).and_return(net_response)
            allow_any_instance_of(Net::HTTPOK).to receive(:read_body).and_return(ok_body_response)

            expect {
              @resp = described_class.new(retailer, customer).send_message(type: 'template', params:
                template_text_params, retailer_user: retailer_user)
            }.to change(GupshupWhatsappMessage, :count).by(1)

            gs_message = GupshupWhatsappMessage.find_by_gupshup_message_id(@resp[:body]['messageId'])
            expect(gs_message.message_payload['isHSM']).to eq('true')
            expect(gs_message.message_payload['type']).to eq('text')
            expect(gs_message.message_payload['text']).to eq('Your Test number 12345 has been updated.')
          end
        end

        context 'when it is sent through template ID' do
          it 'sends the ID of the template and the parameters' do
            allow_any_instance_of(Whatsapp::Gupshup::V1::Base).to receive(:post).and_return(net_response)
            allow_any_instance_of(Net::HTTPOK).to receive(:read_body).and_return(ok_body_response)

            expect {
              @resp = described_class.new(retailer, customer).send_message(type: 'template', params:
                template_id_params, retailer_user: retailer_user)
            }.to change(GupshupWhatsappMessage, :count).by(1)

            gs_message = GupshupWhatsappMessage.find_by_gupshup_message_id(@resp[:body]['messageId'])
            expect(gs_message.message_payload['isHSM']).to eq('true')
            expect(gs_message.message_payload['type']).to eq('text')
            expect(gs_message.message_payload['text']).to eq('Your OTP for Test is abc. This is valid for Today.')
            expect(gs_message.message_payload['id']).to eq('997dd550-c8d8-4bf7-ad98-a5ac4844a1ed')
            expect(gs_message.message_payload['params']).to eq(['Test', 'abc', 'Today'])
          end
        end
      end
    end
  end
end
