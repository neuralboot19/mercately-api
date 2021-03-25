require 'rails_helper'

RSpec.describe Retailers::GsTemplatesController, type: :controller do
  before do
    sign_in retailer_user
  end

  let(:retailer) { create(:retailer) }

  let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }

  let(:valid_attributes) do
    attributes_for(:gs_template)
  end

  let(:invalid_attributes) do
    attributes_for(:gs_template, text: 'Hi {{1}}, {{1}}', example: 'Hi [Daniel], is John')
  end

  describe 'GET #index' do
    it 'returns a success response' do
      retailer.gs_templates.create! valid_attributes
      get :index, params: { slug: retailer_user.retailer.slug }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: { slug: retailer_user.retailer.slug }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new GsTemplate' do
        expect do
          post :create, params: { slug: retailer_user.retailer.slug, gs_template: valid_attributes }
        end.to change(GsTemplate, :count).by(1)
      end

      it 'redirects to the index' do
        post :create, params: { slug: retailer_user.retailer.slug, gs_template: valid_attributes }
        expect(response).to redirect_to(retailers_gs_templates_path(retailer_user.retailer, q:
          { 's': 'created_at desc' }))
      end
    end

    context 'with invalid params' do
      it 'does not creates the template' do
        expect do
          post :create, params: { slug: retailer_user.retailer.slug, gs_template: invalid_attributes }
        end.to change(GsTemplate, :count).by(0)
      end
    end
  end
end
