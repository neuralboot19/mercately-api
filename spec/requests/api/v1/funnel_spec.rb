require 'rails_helper'

RSpec.describe 'Api::V1::FunnelsController', type: :request do
  let!(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let!(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }

  before do
    sign_in retailer_user
  end

  describe 'GET #index' do
    # describe 'when funnel does not exists' do
    #   it 'returns 404' do
    #     get api_v1_funnels_path
    #     expect(response).to have_http_status(404)
    #   end
    # end

    describe 'when funnel exists' do
      let!(:funnel) { create(:funnel, retailer: retailer) }
      let!(:f_step_1) { create(:funnel_step, funnel: funnel) }
      let!(:f_step_2) { create(:funnel_step, funnel: funnel) }
      let!(:deal_1) { create(:deal, name: 'Primera face', funnel_step: f_step_1, retailer: retailer, retailer_user_id: retailer_user.id) }
      let!(:deal_2) { create(:deal, name: 'Negocio 2', funnel_step: f_step_1, retailer: retailer, retailer_user_id: retailer_user.id) }
      let!(:deal_2) { create(:deal, name: 'Negocio 2', funnel_step: f_step_1, retailer: retailer, retailer_user_id: retailer_user.id) }

      it 'returns funnel information' do
        get api_v1_funnels_path, params: { searchText: '' }
        body = JSON.parse(response.body)
        expect(body["funnelSteps"].keys).to eq(["deals", "columns", "columnOrder"])
        expect(body['funnelSteps']['deals'].keys).to eq(funnel.funnel_steps.first.deals.pluck(:web_id))
        expect(body['funnelSteps']['columns'].keys).to eq(funnel.funnel_steps.pluck(:web_id))
        expect(body['funnelSteps']['columnOrder']).to eq(funnel.funnel_steps.pluck(:web_id))
      end

      it 'returns funnel information with deals filtered by searchText' do
        get api_v1_funnels_path, params: { searchText: 'primer' }
        body = JSON.parse(response.body)
        expect(body["funnelSteps"].keys).to eq(["deals", "columns", "columnOrder"])
        expect(body['funnelSteps']['deals'].keys).to eq([deal_1.web_id])
        expect(body['funnelSteps']['columns'].keys).to eq(funnel.funnel_steps.pluck(:web_id))
        expect(body['funnelSteps']['columnOrder']).to eq(funnel.funnel_steps.pluck(:web_id))
      end
    end
  end

  describe 'POST #create_deal' do
    let!(:funnel) { create(:funnel, retailer: retailer) }
    let!(:f_step_1) { create(:funnel_step, funnel: funnel) }

    it 'creates deal succesfully' do

      post create_deal_api_v1_funnels_path, params: {
        deal: {
          name: 'New Deal',
          retailer_user_id: retailer_user.id,
          retailer_id: retailer.id,
          funnel_step_id: f_step_1.id
        }
      }

      expect(response).to have_http_status(:ok)
    end

    it 'returns error message if params are not correct' do
      post create_deal_api_v1_funnels_path, params: {
        deal: {
          retailer_user_id: retailer_user.id
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
