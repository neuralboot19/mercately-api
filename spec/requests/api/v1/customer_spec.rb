require 'rails_helper'

RSpec.describe 'Api::V1::Customers', type: :request do
  let!(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let!(:facebook_retailer) { create(:facebook_retailer, retailer: retailer)}

  let!(:customer1) { create(:customer, :from_fb, retailer: retailer) }
  let!(:customer2) { create(:customer, :from_fb, retailer: retailer) }

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
      get api_v1_customers_path, params: { customerSearch: customer2.first_name }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
    end

    it 'filters customers by last_name' do
      get api_v1_customers_path, params: { customerSearch: customer2.last_name }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
    end

    it 'filters customers by first_name and last_name' do
      get api_v1_customers_path, params: { customerSearch: "#{customer2.first_name} #{customer2.last_name}" }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer2.slice(:id, :email, :first_name, :last_name))
    end

    it 'filters customers by email' do
      get api_v1_customers_path, params: { customerSearch: customer1.email }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer1.slice(:id, :email, :first_name, :last_name))
    end

    it 'filters customers by phone' do
      get api_v1_customers_path, params: { customerSearch: customer1.phone }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body['customers'].count).to eq(1)
      expect(body['customers'][0]).to include(customer1.slice(:id, :email, :first_name, :last_name))
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
end
