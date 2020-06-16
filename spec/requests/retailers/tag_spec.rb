require 'rails_helper'

RSpec.describe 'TagsController', type: :request do
  let(:retailer) { create(:retailer) }
  let(:another_retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }

  describe 'GET #index' do
    context 'when the retailer is not logged in' do
      it 'redirects to login page' do
        get retailers_tags_path(retailer)
        expect(response).to redirect_to('/login')
      end
    end

    context 'when the retailer is logged in' do
      before do
        create_list(:tag, 3, retailer: retailer)
      end

      it 'responses ok' do
        sign_in retailer_user
        get retailers_tags_path(retailer)
        expect(response).to have_http_status(:ok)

        retailer_tags = retailer.tags
        expect(assigns(:tags)).to eq(retailer_tags)
      end
    end
  end

  describe 'GET #show' do
    before do
      sign_in retailer_user
    end

    context 'when the tag does not exist' do
      it 'redirects to dashboard page' do
        get retailers_tag_path(retailer, 'anywebid')
        expect(response).to redirect_to("/retailers/#{retailer.slug}/dashboard")
      end
    end

    context 'when the retailer in session is not the owner' do
      let(:tag) { create(:tag, retailer: another_retailer) }

      it 'redirects to dashboard page' do
        get retailers_tag_path(retailer, tag)
        expect(response).to redirect_to("/retailers/#{retailer.slug}/dashboard")
      end
    end

    context 'when the retailer in session is the owner' do
      let(:tag) { create(:tag, retailer: retailer) }

      it 'responses ok' do
        get retailers_tag_path(retailer, tag)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET #new' do
    before do
      sign_in retailer_user
    end

    it 'responses ok' do
      get new_retailers_tag_path(retailer)
      expect(response).to have_http_status(:ok)
      expect(assigns(:tag)).to be_an_instance_of(Tag)
    end
  end

  describe 'GET #edit' do
    before do
      sign_in retailer_user
    end

    let(:tag) { create(:tag, retailer: retailer) }

    it 'responses ok' do
      get edit_retailers_tag_path(retailer, tag)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    before do
      sign_in retailer_user
    end

    let(:tag) { create(:tag, retailer: retailer) }

    context 'when the required data is supplied' do
      it 'creates a new tag' do
        expect do
          post retailers_tags_path(retailer), params: { tag: { tag: 'Nueva tag' } }
        end.to change(Tag, :count).by(1)
      end
    end

    context 'when the required data is not supplied' do
      it 'does not create the tag' do
        expect do
          post retailers_tags_path(retailer), params: { tag: { tag: '' } }
        end.to change(Tag, :count).by(0)
      end
    end
  end

  describe 'PUT #update' do
    before do
      sign_in retailer_user
    end

    context 'when the required data is supplied' do
      let(:tag) { create(:tag, retailer: retailer, tag: 'Para editar') }

      it 'updates the tag' do
        expect(tag.tag).to eq('Para editar')

        put retailers_tag_path(retailer, tag), params: { tag: { tag: 'Editar tag' } }

        expect(tag.reload.tag).to eq('Editar tag')
      end
    end

    context 'when the required data is not supplied' do
      let(:tag) { create(:tag, retailer: retailer, tag: 'Para no editar') }

      it 'does not update the tag' do
        expect(tag.tag).to eq('Para no editar')

        put retailers_tag_path(retailer, tag), params: { tag: { tag: '' } }

        expect(tag.reload.tag).to eq('Para no editar')
      end
    end
  end

  describe '#destroy' do
    before do
      sign_in retailer_user
    end

    let!(:tag) { create(:tag, retailer: retailer) }

    it 'deletes the tag' do
      expect(Tag.count).to eq(1)

      delete retailers_tag_path(retailer, tag)

      expect(response).to have_http_status(:found)
      expect(Tag.count).to eq(0)
    end

    context 'when the tag has customers associated' do
      let(:customer) { create(:customer, retailer: retailer) }
      let(:anothercustomer) { create(:customer, retailer: retailer) }
      let!(:customer_tag1) { create(:customer_tag, customer: customer, tag: tag) }
      let!(:customer_tag2) { create(:customer_tag, customer: anothercustomer, tag: tag) }

      it 'deletes the relation records as well' do
        expect(CustomerTag.count).to eq(2)

        delete retailers_tag_path(retailer, tag)

        expect(response).to have_http_status(:found)
        expect(CustomerTag.count).to eq(0)
      end
    end
  end
end
