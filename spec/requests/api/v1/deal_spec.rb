require 'rails_helper'

RSpec.describe 'Api::V1::DealsController', type: :request do
  let!(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }

  before do
    sign_in retailer_user
  end

  describe 'DELETE #destroy' do
    let!(:deal) { create(:deal, retailer: retailer, retailer_user: retailer_user) }

    it 'delets deal succesfully' do
      delete api_v1_deal_path(deal.web_id)
      expect(response).to have_http_status(:ok)
    end
    it 'returns error if deal is not found' do
      delete api_v1_deal_path('1')
      expect(response).to have_http_status(422)
    end
  end
end
