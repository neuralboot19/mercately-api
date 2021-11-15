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

  let(:submit_response_pending) do
    {
      'status': 'success',
      'template': {
        'category': 'TICKET_UPDATE',
        'createdOn': 1607593307541,
        'data': 'your ticket has been confirmed for {{1}} persons on date {{2}}.',
        'elementName': 'ticket_check_url_334',
        'id': '7423a738-5193-4cc2-9254-100ee002f98c',
        'languageCode': 'en_US',
        'languagePolicy': 'deterministic',
        'master': true,
        'meta': '{\'example\':\'your ticket has been confirmed for 4 persons on date 2020-05-04.\'}',
        'modifiedOn': 1607593307934,
        'status': 'PENDING',
        'templateType': 'TEXT',
        'vertical': 'BUTTON_CHECK'
      }
    }
  end

  describe 'GET #index' do
    before do
      allow(Connection).to receive(:prepare_connection).and_return(true)
      allow(Connection).to receive(:post_form_request).and_return(double('response', status: 200, body:
        submit_response_pending.to_json))
    end

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
    before do
      allow(Connection).to receive(:prepare_connection).and_return(true)
      allow(Connection).to receive(:post_form_request).and_return(double('response', status: 200, body:
        submit_response_pending.to_json))
    end

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
