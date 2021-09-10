require 'rails_helper';

RSpec.describe "Api::V1::GlobalSettingsController", :type => :request do
  describe "/global_setting" do 
    let!(:global_setting) {create(:global_setting, setting_key: 'test_key', value: '0.0.1')}

    context 'when the request is invalid' do
      before { get '/api/v1/global_settings' }

      it 'return status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'return error key not found' do
        expect(JSON.parse(response.body)["error"]).to eq("key not found")
      end
    end

    context 'when the request is valid' do
      before { get '/api/v1/global_settings', params: { setting_key: 'test_key'} }

      it 'return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'return the right global setting test_key' do
        expect(JSON.parse(response.body)).to eq({global_setting.setting_key => global_setting.value})
      end
    end
  end
end