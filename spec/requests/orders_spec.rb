require 'rails_helper'

RSpec.describe 'Orders', type: :request, skip: true do
  describe 'GET /orders' do
    it 'works! (now write some real specs)' do
      get retailers_orders_path
      expect(response).to have_http_status(:ok)
    end
  end
end
