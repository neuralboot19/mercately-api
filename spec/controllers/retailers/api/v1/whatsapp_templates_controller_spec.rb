require 'rails_helper'

RSpec.describe Retailers::Api::V1::WhatsappTemplatesController, type: :request do
  include ApiDoc::V1::WhatsappTemplates::Api

  describe 'GET #index' do
    include ApiDoc::V1::WhatsappTemplates::Index

    let(:retailer) { create(:retailer, name: 'Test Connection') }
    let(:retailer_user) { create(:retailer_user, retailer: retailer, email: 'retailer@example.com') }
    let!(:whatsapp_template) { create(:whatsapp_template, :with_text, :with_gs_id, retailer: retailer) }

    # Generating credentials for the retailer
    let(:slug) { retailer_user.retailer.slug }
    let(:api_key) { retailer_user.retailer.generate_api_key }

    it 'returns a list of whatsapp templates', :dox do
      get '/retailers/api/v1/whatsapp_templates', headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }

      expect(response).to have_http_status(:ok)
    end
  end
end
