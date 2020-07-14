require 'rails_helper'

RSpec.describe 'SalesChannelsController', type: :request do
  let(:retailer) { create(:retailer) }
  let(:another_retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }

  describe 'GET #index' do
    context 'when the retailer is not logged in' do
      it 'redirects to login page' do
        get retailers_sales_channels_path(retailer)
        expect(response).to redirect_to('/login')
      end
    end

    context 'when the retailer is logged in' do
      before do
        create_list(:sales_channel, 3, retailer: retailer)
      end

      it 'responses ok' do
        sign_in retailer_user
        get retailers_sales_channels_path(retailer)
        expect(response).to have_http_status(:ok)

        retailer_sales = retailer.sales_channels
        expect(assigns(:sales_channels)).to eq(retailer_sales)
      end
    end
  end

  describe 'GET #show' do
    before do
      sign_in retailer_user
    end

    context 'when the sales channel does not exist' do
      it 'redirects to dashboard page' do
        get retailers_sales_channel_path(retailer, 'anywebid')
        expect(response).to redirect_to("/retailers/#{retailer.slug}/dashboard")
      end
    end

    context 'when the retailer in session is not the owner' do
      let(:sales_channel) { create(:sales_channel, retailer: another_retailer) }

      it 'redirects to dashboard page' do
        get retailers_sales_channel_path(retailer, sales_channel)
        expect(response).to redirect_to("/retailers/#{retailer.slug}/dashboard")
      end
    end

    context 'when the retailer in session is the owner' do
      let(:sales_channel) { create(:sales_channel, retailer: retailer) }

      it 'responses ok' do
        get retailers_sales_channel_path(retailer, sales_channel)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET #new' do
    before do
      sign_in retailer_user
    end

    it 'responses ok' do
      get new_retailers_sales_channel_path(retailer)
      expect(response).to have_http_status(:ok)
      expect(assigns(:sales_channel)).to be_an_instance_of(SalesChannel)
    end
  end

  describe 'GET #edit' do
    before do
      sign_in retailer_user
    end

    let(:sales_channel) { create(:sales_channel, retailer: retailer) }

    it 'responses ok' do
      get edit_retailers_sales_channel_path(retailer, sales_channel)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    before do
      sign_in retailer_user
    end

    let(:sales_channel) { create(:sales_channel, retailer: retailer) }

    context 'when the required data is supplied' do
      it 'creates a new sales channel' do
        expect do
          post retailers_sales_channels_path(retailer), params: { sales_channel: { title: 'Nuevo sales channel' } }
        end.to change(SalesChannel, :count).by(1)
      end
    end

    context 'when the required data is not supplied' do
      it 'does not create the sales channel' do
        expect do
          post retailers_sales_channels_path(retailer), params: { sales_channel: { title: '' } }
        end.to change(SalesChannel, :count).by(0)

        expect(assigns(:sales_channel).errors['title'][0]).to eq('Título no puede estar vacío')
      end
    end
  end

  describe 'PUT #update' do
    before do
      sign_in retailer_user
    end

    context 'when the required data is supplied' do
      let(:sales_channel) { create(:sales_channel, retailer: retailer, title: 'Para editar') }

      it 'updates the sales channel' do
        expect(sales_channel.title).to eq('Para editar')

        put retailers_sales_channel_path(retailer, sales_channel), params:
          {
            sales_channel:
              {
                title: 'Editar sales channel'
              }
          }

        expect(sales_channel.reload.title).to eq('Editar sales channel')
      end
    end

    context 'when the required data is not supplied' do
      let(:sales_channel) { create(:sales_channel, retailer: retailer, title: 'Para no editar') }

      it 'does not update the sales channel' do
        expect(sales_channel.title).to eq('Para no editar')

        put retailers_sales_channel_path(retailer, sales_channel), params: { sales_channel: { title: '' } }

        expect(sales_channel.reload.title).to eq('Para no editar')
        expect(assigns(:sales_channel).errors['title'][0]).to eq('Título no puede estar vacío')
      end
    end
  end

  describe '#destroy' do
    before do
      sign_in retailer_user
    end

    context 'when the sales channel type is mercadolibre' do
      let!(:sales_channel) { create(:sales_channel, :mercado_libre, retailer: retailer) }

      it 'does not delete the sales channel' do
        expect(SalesChannel.count).to eq(1)

        delete retailers_sales_channel_path(retailer, sales_channel)

        expect(response).to have_http_status(:found)
        expect(SalesChannel.count).to eq(1)
        expect(assigns(:sales_channel).errors['base'][0]).to eq(
          'Canal no se puede eliminar, pertenece a una integración'
        )
      end
    end

    context 'when the sales channel type is messenger' do
      let!(:sales_channel) { create(:sales_channel, :messenger, retailer: retailer) }

      it 'does not delete the sales channel' do
        expect(SalesChannel.count).to eq(1)

        delete retailers_sales_channel_path(retailer, sales_channel)

        expect(response).to have_http_status(:found)
        expect(SalesChannel.count).to eq(1)
        expect(assigns(:sales_channel).errors['base'][0]).to eq(
          'Canal no se puede eliminar, pertenece a una integración'
        )
      end
    end

    context 'when the sales channel type is whatsapp' do
      let!(:sales_channel) { create(:sales_channel, :whatsapp, retailer: retailer) }

      it 'does not delete the sales channel' do
        expect(SalesChannel.count).to eq(1)

        delete retailers_sales_channel_path(retailer, sales_channel)

        expect(response).to have_http_status(:found)
        expect(SalesChannel.count).to eq(1)
        expect(assigns(:sales_channel).errors['base'][0]).to eq(
          'Canal no se puede eliminar, pertenece a una integración'
        )
      end
    end

    context 'when the sales channel type is other' do
      let!(:sales_channel) { create(:sales_channel, retailer: retailer) }

      it 'deletes the sales channel' do
        expect(SalesChannel.count).to eq(1)

        delete retailers_sales_channel_path(retailer, sales_channel)

        expect(response).to have_http_status(:found)
        expect(SalesChannel.count).to eq(0)
      end
    end

    context 'when the sales channel has at least one order associated' do
      let(:sales_channel) { create(:sales_channel, retailer: retailer) }
      let!(:order) { create(:order, sales_channel: sales_channel) }

      it 'does not delete the sales channel' do
        expect(SalesChannel.count).to eq(1)

        delete retailers_sales_channel_path(retailer, sales_channel)

        expect(response).to have_http_status(:found)
        expect(SalesChannel.count).to eq(1)
        expect(assigns(:sales_channel).errors['base'][0]).to eq(
          'Canal no se puede eliminar, posee ventas asociadas'
        )
      end
    end

    context 'when the sales channel does not have orders associated' do
      let!(:sales_channel) { create(:sales_channel, retailer: retailer) }

      it 'does not delete the sales channel' do
        expect(SalesChannel.count).to eq(1)

        delete retailers_sales_channel_path(retailer, sales_channel)

        expect(response).to have_http_status(:found)
        expect(SalesChannel.count).to eq(0)
      end
    end
  end
end
