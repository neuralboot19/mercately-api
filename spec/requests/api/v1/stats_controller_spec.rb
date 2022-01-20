require 'rails_helper';

RSpec.describe "Api::V1::StatsController", :type => :request do
  let(:retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let(:customer) { create(:customer, retailer: retailer) }
  let!(:chat_history) { create(:chat_history, retailer_user: retailer_user, customer: customer, chat_status: 1, created_at: '2021-12-29 15:34:32.836687') }

  before do
    sign_in retailer_user
  end

  describe "/agent_performance" do
    context 'when the request is invalid' do
      before { get '/api/v1/stats/agent_performance' }

      it 'return status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'return error not records' do
        expect(JSON.parse(response.body)["error"]).to eq("not records")
      end
    end

    context 'when the request is valid' do
      before { get '/api/v1/stats/agent_performance', params: { retailer_id: retailer.id, start_date: '2021-12-29', end_date: '2021-12-30'} }

      it 'return status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'return one record with amount_chat_in_process in 1' do
        expect(JSON.parse(response.body)["agent_performance"][0]["amount_chat_in_process"]).to eq(1)
      end

      it 'return one record with amount_chat_in_process in 1' do
        expect(JSON.parse(response.body)["agent_performance"][0]["amount_chat_resolved"]).to eq(0)
      end
    end
  end
end