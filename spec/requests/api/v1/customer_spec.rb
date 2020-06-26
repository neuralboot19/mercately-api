require 'rails_helper'

RSpec.describe 'Api::V1::CustomersController', type: :request do
  let!(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let!(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }

  let!(:customer1) { create(:customer, :from_fb, retailer: retailer, first_name: 'First', last_name: 'Example') }
  let!(:customer2) { create(:customer, :from_fb, retailer: retailer, first_name: 'Another', last_name: 'Test') }

  before do
    # Facebook messages for customer1 and customer2
    create_list(:facebook_message, 6, facebook_retailer: facebook_retailer, customer: customer1, date_read: Date.today)
    create_list(:facebook_message, 6, facebook_retailer: facebook_retailer, customer: customer2, date_read: Date.today)

    sign_in retailer_user
  end

  describe 'GET #index' do
    describe 'when the current retailer user is admin' do
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

    describe 'when current retailer user is agent' do
      before do
        retailer_user.update_attribute(:retailer_admin, false)
      end

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

    context 'when the tag filter is present' do
      context 'when the tag filter is "all"' do
        let!(:tag) { create(:tag, retailer: retailer) }
        let!(:customer_tag) { create(:customer_tag, tag: tag, customer: customer1) }

        it 'responses the customers with (any tag assigned/without tags assigned)' do
          get api_v1_customers_path, params: { tag: 'all' }
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['customers'].count).to eq(2)
        end
      end

      context 'when the tag filter is not "all"' do
        let(:tag) { create(:tag, retailer: retailer) }
        let!(:customer_tag) { create(:customer_tag, tag: tag, customer: customer1) }

        it 'responses only the customers with the tag assigned' do
          get api_v1_customers_path, params: { tag: tag.id }
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['customers'].count).to eq(1)
        end
      end
    end

    context 'when the agent filter is present' do
      context 'when the agent filter is "all"' do
        it 'responses with all customers' do
          get api_v1_customers_path, params: { agent: 'all' }
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['customers'].count).to eq(2)
        end
      end

      context 'when the agent filter is not "all"' do
        let(:agent) { create(:retailer_user, :agent, retailer: retailer) }
        let!(:agent_customer) do
          create(:agent_customer, retailer_user: agent, customer: customer1)
        end

        it 'responses only the customers with the agent assigned' do
          get api_v1_customers_path, params: { agent: agent.id }
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['customers'].count).to eq(1)
        end
      end
    end

    context 'when the type filter is present' do
      context 'when is "all"' do
        it 'responses with all customers' do
          get api_v1_customers_path, params: { type: 'all' }
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['customers'].count).to eq(2)
        end
      end

      context 'when is "no_read"' do
        it 'responses only the customers with no read messages' do
          customer1.facebook_messages.first.update(date_read: nil)
          get api_v1_customers_path, params: { type: 'no_read' }
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['customers'].count).to eq(1)
        end

        it 'responses only the customers with chat set as no read' do
          customer1.update(unread_messenger_chat: true)
          get api_v1_customers_path, params: { type: 'no_read' }
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['customers'].count).to eq(1)
        end
      end

      context 'when is "read"' do
        it 'responses only the customers with read messages' do
          customer1.facebook_messages.update_all(date_read: nil)
          get api_v1_customers_path, params: { type: 'read' }

          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['customers'].count).to eq(1)
          expect(body['customers'].first['id']).to eq(customer2.id)
        end

        it 'responses only the customers with no read messenger chat' do
          customer2.update(unread_messenger_chat: true)

          get api_v1_customers_path, params: { type: 'no_read' }
          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['customers'].count).to eq(1)
          expect(body['customers'].first['id']).to eq(customer2.id)
        end
      end
    end

    context 'when param order is present' do
      before do
        FacebookMessage.all.each_with_index do |m, index|
          m.created_at = Time.now - (5 * index).seconds
          m.save
        end
      end

      context 'when is received in ascending order' do
        it 'responses customers ordered by facebook_messages.created_at in ascending order' do
          get api_v1_customers_path, params: { order: 'received_asc' }

          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['customers'].count).to eq(2)

          message = FacebookMessage.where(customer_id: retailer.customers.ids).order('created_at ASC').first
          expect(body['customers'].first['id']).to eq(message.customer_id)
        end
      end

      context 'when is received in descending order' do
        it 'responses customers ordered by facebook_messages.created_at in descending order' do
          get api_v1_customers_path, params: { order: 'received_desc' }

          body = JSON.parse(response.body)

          expect(response).to have_http_status(:ok)
          expect(body['customers'].count).to eq(2)

          message = FacebookMessage.where(customer_id: retailer.customers.ids).order('created_at DESC').first
          expect(body['customers'].first['id']).to eq(message.customer_id)
        end
      end
    end
  end

  describe 'GET #show' do
    let(:customer) { create(:customer, retailer: retailer) }
    let(:tag) { create(:tag, retailer: retailer, tag: 'Prueba 1') }
    let!(:tag2) { create(:tag, retailer: retailer, tag: 'Prueba 2') }
    let!(:customer_tag) { create(:customer_tag, tag: tag, customer: customer) }

    it 'returns the customer data' do
      get api_v1_customer_path(customer.id)
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customer']).not_to be nil
    end

    context 'when the customer has tags' do
      it 'returns the tags assigned' do
        get api_v1_customer_path(customer.id)
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customer']).not_to be nil
        expect(body['customer']['tags'].size).to eq(1)
        expect(body['customer']['tags'][0]['tag']).to eq('Prueba 1')
      end
    end

    context 'when the retailer has tags created' do
      it 'returns the tags that the customer does not have assigned yet' do
        get api_v1_customer_path(customer.id)
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['customer']).not_to be nil
        expect(body['customer']['tags'].size).to eq(1)
        expect(body['customer']['tags'][0]['tag']).to eq('Prueba 1')
        expect(body['tags'].size).to eq(1)
        expect(body['tags'][0]['tag']).to eq('Prueba 2')
      end
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
        expect(body['customer'].keys).to include('tags')
        expect(body.keys).to include('tags')
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
        expect(body['customer'].keys).to include('tags')
        expect(body.keys).to include('tags')
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

    context 'when file is an argument' do
      it 'creates a new messenger file message' do
        post api_v1_send_img_path(customer1.id), params: { file_data:
          fixture_file_upload(Rails.root + 'spec/fixtures/profile.jpg', 'image/jpeg') }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['message']['id']).to eq(FacebookMessage.last.id)
        expect(body['message']['retailer_user_id']).to eq(retailer_user.id)
      end
    end

    context 'when url is an argument' do
      it 'creates a new messenger file message' do
        post api_v1_send_img_path(customer1.id), params: { url:
          'https://www.images.com/image.jpg', type: 'image' }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['message']['id']).to eq(FacebookMessage.last.id)
        expect(body['message']['retailer_user_id']).to eq(retailer_user.id)
      end
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

  describe 'GET #selectable_tags' do
    let(:customer) { create(:customer, retailer: retailer) }
    let!(:tag) { create(:tag, retailer: retailer, tag: 'Prueba 1') }
    let!(:tag2) { create(:tag, retailer: retailer, tag: 'Prueba 2') }

    context 'when the customer has no tags assigned' do
      it 'returns all the retailer tags' do
        get api_v1_selectable_tags_path(customer.id)
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['tags'].size).to eq(2)
      end
    end

    context 'when the customer has tags assigned' do
      let!(:customer_tag) { create(:customer_tag, tag: tag, customer: customer) }

      it 'returns all not assigned tags' do
        get api_v1_selectable_tags_path(customer.id)
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(body['tags'].size).to eq(1)
        expect(body['tags'][0]['tag']).to eq('Prueba 2')
      end
    end
  end

  describe 'POST #add_customer_tag' do
    let(:customer) { create(:customer, retailer: retailer) }
    let(:tag) { create(:tag, retailer: retailer, tag: 'Prueba 1') }
    let!(:tag2) { create(:tag, retailer: retailer, tag: 'Prueba 2') }

    it 'assigns a new tag to the customer' do
      expect(customer.customer_tags.size).to eq(0)

      post api_v1_add_customer_tag_path(customer.id), params: { tag_id: tag.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(customer.customer_tags.reload.size).to eq(1)
      expect(body['customer']['tags'].size).to eq(1)
      expect(body['customer']['tags'][0]['tag']).to eq('Prueba 1')
      expect(body['tags'].size).to eq(1)
      expect(body['tags'][0]['tag']).to eq('Prueba 2')
    end
  end

  describe 'DELETE #remove_customer_tag' do
    let(:customer) { create(:customer, retailer: retailer) }
    let(:tag) { create(:tag, retailer: retailer, tag: 'Prueba 1') }
    let!(:tag2) { create(:tag, retailer: retailer, tag: 'Prueba 2') }
    let!(:customer_tag) { create(:customer_tag, tag: tag, customer: customer) }

    it 'removes the tag from the customer' do
      expect(customer.customer_tags.size).to eq(1)

      delete api_v1_remove_customer_tag_path(customer.id), params: { tag_id: tag.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(customer.customer_tags.reload.size).to eq(0)
      expect(body['customer']['tags'].size).to eq(0)
      expect(body['tags'].size).to eq(2)
    end
  end

  describe 'POST #add_tag' do
    let(:customer) { create(:customer, retailer: retailer) }
    let!(:tag) { create(:tag, retailer: retailer, tag: 'Prueba 1') }

    it 'adds a new tag to the retailer and assigns it to the customer' do
      expect(customer.customer_tags.size).to eq(0)
      expect(retailer.tags.size).to eq(1)

      post api_v1_add_tag_path(customer.id), params: { tag: 'Prueba 2' }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(customer.customer_tags.reload.size).to eq(1)
      expect(retailer.tags.reload.size).to eq(2)
      expect(body['customer']['tags'].size).to eq(1)
      expect(body['customer']['tags'][0]['tag']).to eq('Prueba 2')
      expect(body['tags'].size).to eq(1)
      expect(body['tags'][0]['tag']).to eq('Prueba 1')
    end
  end
end
