require 'rails_helper'

RSpec.describe 'StripeController', type: :request do
  describe "POST #webhook" do
    it "returns http success" do
      post '/stripe/webhook'
      expect(response).to have_http_status(:success)
    end
  end
end
