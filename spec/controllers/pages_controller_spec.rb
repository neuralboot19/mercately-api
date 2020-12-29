require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe 'pages_controller' do
    it "GET #whatsapp_crm" do
      get :whatsapp_crm
      expect(assigns(:show_checkbox_recaptcha)).to eq(true)
    end
  end
end
