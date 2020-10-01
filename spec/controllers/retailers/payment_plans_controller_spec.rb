require 'rails_helper'

RSpec.describe Retailers::PaymentPlansController, type: :controller do
  let(:retailer) { create(:retailer, :gupshup_integrated) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let(:retailer_no_ws) { create(:retailer) }
  let(:retailer_user_no_ws) { create(:retailer_user, retailer: retailer_no_ws) }

  before do
    sign_in retailer_user
  end

  describe 'GET #index' do
    context 'when the retailer is whatsapp integrated' do
      let(:customer1) { create(:customer, retailer: retailer) }
      let(:customer2) { create(:customer, retailer: retailer) }
      let!(:customer4) { create(:customer, retailer: retailer) }
      let(:customer3) { create(:customer, retailer: retailer_no_ws) }

      let!(:chat_bot_customer1) { create(:chat_bot_customer, customer: customer1, created_at: Time.now - 1.month) }
      let!(:chat_bot_customer2) { create(:chat_bot_customer, customer: customer2, created_at: Time.now - 15.days) }
      let!(:chat_bot_customer3) { create(:chat_bot_customer, customer: customer3, created_at: Time.now - 1.month) }

      before do
        retailer.payment_plan.update(start_date: Time.now - 2.months)
      end

      it 'loads the counter of chatbots interactions' do
        get :index, params: { slug: retailer.slug }

        expect(assigns(:interactions).map { |int| int[:total] }.sum).to eq(2)
      end
    end

    context 'when the retailer is not whatsapp integrated' do
      let(:customer3) { create(:customer, retailer: retailer_no_ws) }

      before do
        sign_out retailer_user
        sign_in retailer_user_no_ws

        retailer_no_ws.payment_plan.update(start_date: Time.now - 2.months)
      end

      it 'does not load the counter of chatbots interactions' do
        get :index, params: { slug: retailer_no_ws.slug }

        expect(assigns(:interactions)).to be nil
      end
    end
  end
end
