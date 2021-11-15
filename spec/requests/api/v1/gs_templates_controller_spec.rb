require 'rails_helper';

RSpec.describe "Api::V1::GsTemplatesController", :type => :request do

  let!(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }

  let(:valid_attributes) do
    attributes_for(:gs_template, key: 'text')
  end

  let(:invalid_attributes) do
    attributes_for(:gs_template, key: 'text', text: 'Hi {{1}}, {{1}}', example: 'Hi [Jhon], is Doe', file: nil)
  end

  let(:submit_response_pending) do
    {
      'status': 'success',
      'template': {
        'category': 'TICKET_UPDATE',
        'createdOn': 1607593307541,
        'data': 'your ticket has been confirmed for {{1}} persons on date {{2}}.',
        'elementName': 'ticket_check_url_334',
        'id': '7423a738-5193-4cc2-9254-100ee002f98c',
        'languageCode': 'en_US',
        'languagePolicy': 'deterministic',
        'master': true,
        'meta': '{\'example\':\'your ticket has been confirmed for 4 persons on date 2020-05-04.\'}',
        'modifiedOn': 1607593307934,
        'status': 'PENDING',
        'templateType': 'TEXT',
        'vertical': 'BUTTON_CHECK'
      }
    }
  end

  before do
    sign_in retailer_user
  end

  describe 'POST #create_gs_template' do
    context 'with valid params' do
      before do
        allow(Connection).to receive(:prepare_connection).and_return(true)
        allow(Connection).to receive(:post_form_request).and_return(double('response', status: 200, body:
          submit_response_pending.to_json))

        post api_v1_gs_templates_path, params: {
          gs_template: valid_attributes
        }
      end

      it 'return status code ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'return message: Plantilla creada con éxito' do
        expect(JSON.parse(response.body)["message"]).to eq('Plantilla creada con éxito')
      end
    end

    context 'with invalid params' do
      before do
        post api_v1_gs_templates_path, params: {
          gs_template: invalid_attributes
        }
      end

      it 'return status code bad_request' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'return message: Error al crear plantilla' do
        expect(JSON.parse(response.body)["message"]).to eq('Error al crear plantilla')
      end

      it 'returns validate message' do
        expect(JSON.parse(response.body)["errors"]["base"][0]).to eq('Hay variables repetidas')
      end
    end
  end
end