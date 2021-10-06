require 'rails_helper';

RSpec.describe "Api::V1::GsTemplatesController", :type => :request do

  let!(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }

  let(:valid_attributes) do
    attributes_for(:gs_template)
  end

  let(:invalid_attributes) do
    attributes_for(:gs_template, text: 'Hi {{1}}, {{1}}', example: 'Hi [Jhon], is Doe')
  end

  before do
    sign_in retailer_user
  end

  describe 'POST #create_gs_template' do
    context 'with valid params' do
      before do
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