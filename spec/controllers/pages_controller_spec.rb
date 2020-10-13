require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  let!(:category) { create(:category) }
  let!(:retailer) { create(:retailer) }
  let!(:product1) { create(:product, :from_ml, retailer: retailer, category: category) }
  let!(:product2) { create(:product, :from_ml, retailer: retailer, category: category) }


  describe 'pages_controller' do
    it "GET #whatsapp_crm" do
      get :whatsapp_crm
      expect(assigns(:show_checkbox_recaptcha)).to eq(true)
    end

    it "GET #retailers product" do
      get :catalog , params: { slug: retailer.slug }
      expect(assigns(:products).count).to eq(2)
    end

    it "GET #product" do
      get :product , params: { slug: retailer.slug , web_id: product1.web_id}
      expect(assigns(:product)).to eq(product1)
    end
  end
end
