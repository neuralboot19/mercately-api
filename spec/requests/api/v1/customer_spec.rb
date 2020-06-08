require 'rails_helper'

RSpec.describe 'Api::V1::CustomersController', type: :request do
  let!(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let!(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }

  let!(:customer1) { create(:customer, :from_fb, retailer: retailer, first_name: 'First', last_name: 'Example') }
  let!(:customer2) { create(:customer, :from_fb, retailer: retailer, first_name: 'Another', last_name: 'Test') }

  before do
    # Facebook messages for customer1 and customer2
    create_list(:facebook_message, 6, facebook_retailer: facebook_retailer, customer: customer1)
    create_list(:facebook_message, 6, facebook_retailer: facebook_retailer, customer: customer2)

    sign_in retailer_user
  end

  describe 'GET #index' do
    it 'responses with all customers' do
      get api_v1_customers_path
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(2)
    end

    it 'filters customers by first_name' do
      get api_v1_customers_path, params: { searchString: customer2.first_name }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
    end

    it 'filters customers by last_name' do
      get api_v1_customers_path, params: { searchString: customer2.last_name }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
    end

    it 'filters customers by first_name and last_name' do
      get api_v1_customers_path, params: { searchString: "#{customer2.first_name} #{customer2.last_name}" }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
    end

    it 'filters customers by email' do
      get api_v1_customers_path, params: { searchString: customer1.email }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer1.slice(:id, :email, :first_name, :last_name))
    end

    it 'filters customers by phone' do
      get api_v1_customers_path, params: { searchString: customer1.phone }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer1.slice(:id, :email, :first_name, :last_name))
    end
  end

  describe 'GET #show' do
    it 'returns the customer data' do
      get api_v1_customer_path(customer1.id)
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customer']).not_to be nil
    end
  end

  describe 'PUT #update' do
    let(:customer) { create(:customer) }

    let(:data) do
      {
        first_name: 'Example',
        last_name: 'Test',
        phone: '+593123456789',
        email: 'example@test.com'
      }
    end

    context 'when data is correct' do
      it 'updates the customer' do
        put api_v1_customer_path(customer.id), params: { customer: data }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customer']['email']).to eq(data[:email])
        expect(body['errors']).to be nil
      end
    end

    context 'when some attribute is not correct' do
      it 'does not update the customer' do
        data[:email] = 'example@test.'
        put api_v1_customer_path(customer.id), params: { customer: data }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:bad_request)
        expect(body['errors']).not_to be nil
        expect(body['errors']['email']).to eq(['invalido'])
      end
    end
  end

  describe 'GET #messages' do
    let(:set_facebook_messages_service) { instance_double(Facebook::Messages) }

    before do
      allow(set_facebook_messages_service).to receive(:send_read_action)
        .and_return('Read')
      allow(Facebook::Messages).to receive(:new).with(facebook_retailer)
        .and_return(set_facebook_messages_service)
    end

    it 'responses the customer messages' do
      get api_v1_customer_messages_path(customer1.id)
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['messages'].count).to eq(6)
    end
  end

  # describe 'POST #create_message' do
  # end

  describe 'POST #set_message_as_read' do
    let(:set_facebook_messages_service) { instance_double(Facebook::Messages) }

    before do
      allow(set_facebook_messages_service).to receive(:send_read_action)
        .and_return('Read')
      allow(Facebook::Messages).to receive(:new).with(facebook_retailer)
        .and_return(set_facebook_messages_service)
    end

    it 'sets the message as read' do
      post api_v1_set_message_as_read_path(customer1.facebook_messages.last.id)
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['message']['date_read']).not_to be nil
    end
  end

  describe 'GET #fast_answers_for_messenger' do
    before do
      create_list(:template, 3, :for_messenger, retailer: retailer)
      create_list(:template, 2, :for_whatsapp, retailer: retailer)
      create_list(:template, 2, :for_messenger, retailer: retailer, title: 'Texto de prueba')
      create(:template, :for_messenger, retailer: retailer, answer: 'Contenido de prueba')
    end

    it 'returns a messenger fast answers list' do
      get api_v1_fast_answers_for_messenger_path
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['templates']['data'].count).to eq(6)
    end

    it 'filters by title' do
      get api_v1_fast_answers_for_messenger_path, params: { search: 'texto' }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['templates']['data'].count).to eq(2)
      expect(body['templates']['data'][0]['attributes']['title']).to include('Texto')
    end

    it 'filters by content' do
      get api_v1_fast_answers_for_messenger_path, params: { search: 'contenido' }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['templates']['data'].count).to eq(1)
      expect(body['templates']['data'][0]['attributes']['answer']).to include('Contenido')
    end
  end

  describe 'GET #messages' do
    let(:set_facebook_messages_service) { instance_double(Facebook::Messages) }

    before do
      allow(set_facebook_messages_service).to receive(:send_read_action)
        .and_return('Read')
      allow(Facebook::Messages).to receive(:new).with(facebook_retailer)
        .and_return(set_facebook_messages_service)
    end

    it 'responses with the customer messages' do
      get api_v1_customer_messages_path(customer1.id)
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['messages'].count).to eq(6)
    end
  end

  describe 'POST #set_message_as_read' do
    let(:set_facebook_messages_service) { instance_double(Facebook::Messages) }

    before do
      allow(set_facebook_messages_service).to receive(:send_read_action)
        .and_return('Read')
      allow(Facebook::Messages).to receive(:new).with(facebook_retailer)
        .and_return(set_facebook_messages_service)
    end

    it 'sets the message as read' do
      post api_v1_set_message_as_read_path(customer1.facebook_messages.last.id)
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['message']['date_read']).not_to be nil
    end
  end

  describe 'POST #create_message' do
    let(:set_facebook_messages_service) { instance_double(Facebook::Messages) }

    before do
      allow(set_facebook_messages_service).to receive(:send_message)
        .and_return('Sent')
      allow(Facebook::Messages).to receive(:new).with(facebook_retailer)
        .and_return(set_facebook_messages_service)
    end

    it 'creates a new messenger text message' do
      post api_v1_create_message_path(customer1.id), params: { message: 'Texto' }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['message']['id']).to eq(FacebookMessage.last.id)
      expect(body['message']['retailer_user_id']).to eq(retailer_user.id)
    end
  end

  describe 'POST #send_img' do
    let(:set_facebook_messages_service) { instance_double(Facebook::Messages) }

    before do
      allow(set_facebook_messages_service).to receive(:send_attachment)
        .and_return('Sent')
      allow(Facebook::Messages).to receive(:new).with(facebook_retailer)
        .and_return(set_facebook_messages_service)
    end

    it 'creates a new messenger file message' do
      post api_v1_send_img_path(customer1.id), params: { file_data:
        fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg') }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['message']['id']).to eq(FacebookMessage.last.id)
      expect(body['message']['retailer_user_id']).to eq(retailer_user.id)
    end
  end

  describe 'PATCH #accept_opt_in' do
    context 'when Gupshup integrated' do
      let(:retailer_gupshup) { create(:retailer, :gupshup_integrated) }
      let(:retailer_user_gupshup) { create(:retailer_user, :admin, retailer: retailer_gupshup) }
      let(:customer_optin_false) { create(:customer, retailer: retailer_gupshup, whatsapp_opt_in: false) }

      let(:service_response) {
        {:code=>"200", :body=>{"status"=>true}}
      }

      before do
        allow(CSV).to receive(:open).and_return(true)
        allow(File).to receive(:open).and_return(true)
        allow(File).to receive(:delete).and_return(true)
        allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Users).to receive(:upload_list).and_return(service_response)

        sign_out retailer_user
        sign_in retailer_user_gupshup
      end

      it 'will response a 200 status code and updates whatsapp_opt_in to true' do
        patch "/api/v1/accept_optin_for_whatsapp/#{customer_optin_false.id}"
        expect(response.code).to eq('200')
      end

      it 'will response a 400 status code if opt-in not updated' do
        allow_any_instance_of(Customer).to receive(:accept_opt_in!).and_return(false)
        patch "/api/v1/accept_optin_for_whatsapp/#{customer_optin_false.id}"

        body = JSON.parse(response.body)

        expect(response.code).to eq('400')
        expect(body['error']).to eq('Error al aceptar opt-in de este cliente, intente nuevamente')
      end

    end
  end
end
