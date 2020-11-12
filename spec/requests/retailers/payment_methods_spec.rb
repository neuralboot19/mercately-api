require 'rails_helper'

RSpec.describe 'PaymentMethodsController', type: :request do
  let(:retailer_user) { create(:retailer_user, :with_retailer, first_name: '', last_name: '' ) }

  let(:stripe_customer_update_mock) do
    {
      'id': 'cus_HzoFvpqGDAHupM',
      'object': 'customer',
      'address': nil,
      'balance': 0,
      'created': 1599739880,
      'currency': 'usd',
      'default_source': nil,
      'delinquent': false,
      'description': nil,
      'discount': nil,
      'email': nil,
      'invoice_prefix': 'E799703',
      'invoice_settings': {
        'custom_fields': nil,
        'default_payment_method': nil,
        'footer': nil
      },
      'livemode': false,
      'metadata': {
        'order_id': '6735'
      },
      'name': nil,
      'next_invoice_sequence': 1,
      'phone': nil,
      'preferred_locales': [],
      'shipping': nil,
      'tax_exempt': 'none'
    }.with_indifferent_access
  end

  let(:stripe_customer_list_mock) do
    [
      {
        'id': 'cus_00000000000001',
        'object': 'customer',
        'address': nil,
        'balance': 0,
        'created': 1599656898,
        'currency': 'usd',
        'default_source': nil,
        'delinquent': false,
        'description': nil,
        'discount': nil,
        'email': nil,
        'invoice_prefix': '1152C9C',
        'invoice_settings': {
          'custom_fields': nil,
          'default_payment_method': nil,
          'footer': nil
        },
        'livemode': false,
        'metadata': {},
        'name': nil,
        'next_invoice_sequence': 1,
        'phone': nil,
        'preferred_locales': [],
        'shipping': nil,
        'tax_exempt': 'none'
      }.with_indifferent_access,
    ]
  end

  let(:stripe_setup_intent_mock) do
    {
      'created': 1326853478,
      'livemode': false,
      'id': 'evt_00000000000000',
      'type': 'setup_intent.created',
      'object': 'event',
      'request': nil,
      'pending_webhooks': 1,
      'api_version': '2020-03-02',
      'data': {
        'object': {
          'id': 'seti_00000000000000',
          'object': 'setup_intent',
          'application': nil,
          'cancellation_reason': nil,
          'client_secret': 'seti_1GzqBtHiB9RqDUjMhnr02z1x_secret_HYy8zIWSVwIbkURWhSYuqot6HBxurdL',
          'created': 1593549389,
          'customer': 'cus_00000000000000',
          'description': nil,
          'last_setup_error': nil,
          'livemode': false,
          'mandate': nil,
          'metadata': {
          },
          'next_action': nil,
          'on_behalf_of': nil,
          'payment_method': nil,
          'payment_method_options': {
            'card': {
              'request_three_d_secure': 'automatic'
            }
          },
          'payment_method_types': [
            'card'
          ],
          'single_use_mandate': nil,
          'status': 'requires_payment_method',
          'usage': 'off_session'
        }
      }
    }.with_indifferent_access
  end

  let(:payment_method_retrieve_mock) do
     {
      'id': 'pm_1Gzr6iHiB9RqDUjMLY8lETlS',
      'object': 'payment_method',
      'billing_details': {
        'address': {
          'city': nil,
          'country': nil,
          'line1': nil,
          'line2': nil,
          'postal_code': '42424',
          'state': nil
        },
        'email': nil,
        'name': nil,
        'phone': nil
      },
      'card': {
        'brand': 'visa',
        'checks': {
          'address_line1_check': nil,
          'address_postal_code_check': 'pass',
          'cvc_check': 'pass'
        },
        'country':'US',
        'exp_month': 4,
        'exp_year': 2024,
        'fingerprint': 'WC1OHKUFBVIKfSp6',
        'funding': 'credit',
        'generated_from': nil,
        'last4':'4242',
        'networks': {
          'available': ['visa'],
          'preferred': nil
        },
        'three_d_secure_usage': {'supported':true},
        'wallet': nil
      },
      'created': 1593552913,
      'customer': 'cus_00000000000000',
      'livemode': false,
      'metadata': {},
      'type': 'card'
    }.with_indifferent_access
  end

  let(:customer_update_payment_method_mock) do
    {'invoice_settings': {'default_payment_method': 'pm_1Gzr6iHiB9RqDUjMLY8lETlS'}}.with_indifferent_access
  end

  before do
    sign_in retailer_user
    allow(Stripe::Customer).to receive(:list).and_return(stripe_customer_list_mock)
    allow(Stripe::Customer).to receive(:create).and_return({customer: { 'id': 'cus_00000000000000' }})
    allow(Stripe::Customer).to receive(:update).and_return(stripe_customer_update_mock)
    allow(Stripe::SetupIntent).to receive(:create).and_return(stripe_setup_intent_mock)
    allow(Stripe::PaymentMethod).to receive(:retrieve).and_return(payment_method_retrieve_mock)
  end

  describe 'POST #create-setup-intent' do
    it 'returns stripe setup intent data' do
      post retailers_payment_create_setup_intent_path(retailer_user.retailer)
      body = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(body['data']['data']['object']['id']).to eq('seti_00000000000000')
      expect(body['data']['data']['object']['object']).to eq('setup_intent')
      expect(body['data']['type']).to eq('setup_intent.created')
    end

    it 'returns stripe customer id found' do
      expect(Stripe::SetupIntent).to receive(:create).with(customer: 'cus_0000000000000')

      stripe_customer_list_mock[0][:id] = 'cus_0000000000000'
      stripe_customer_list_mock[0][:description] = retailer_user.retailer.name
      stripe_customer_list_mock[0][:email] = retailer_user.email

      post retailers_payment_create_setup_intent_path(retailer_user.retailer)
      expect(response.status).to eq(200)
    end

    it 'returns stripe customer id stored' do
      payment_method = create(:payment_method, retailer: retailer_user.retailer)
      customer = JSON.parse(payment_method.payment_payload)['customer']
      expect(Stripe::SetupIntent).to receive(:create).with(customer: customer)

      post retailers_payment_create_setup_intent_path(retailer_user.retailer)
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #create' do
    it 'creates a new payment method for the retailer' do
      post retailers_payment_methods_path(retailer_user.retailer, payment_method: 'pm_1Gzr6iHiB9RqDUjMLY8lETlS')
      body = JSON.parse(response.body)

      expect(response.status).to eq(200)

      last_pm = PaymentMethod.last
      expect(flash[:notice]).to be_present
      expect(flash[:notice]).to eq('Método de pago almacenado con éxito.')
      expect(body['data']).to eq(last_pm.payment_payload)
    end

    it 'updates customer with payment method' do

      payment_method = create(
        :payment_method,
        retailer: retailer_user.retailer,
        stripe_pm_id: payment_method_retrieve_mock['id']
      )

      customer_id = JSON.parse(payment_method.payment_payload)['customer']

      stripe_customer_params = {
        'invoice_settings': {
          'default_payment_method': payment_method_retrieve_mock['id'],
        },
      }
      expect(Stripe::Customer).to receive(:update).with(customer_id, stripe_customer_params)

      post retailers_payment_methods_path(retailer_user.retailer, payment_method: payment_method.stripe_pm_id)
      expect(response.status).to eq(200)
    end

    it 'response with an error if stripe pops an exception when retrieving Customer update' do
      error = Stripe::InvalidRequestError.new('s', {})
      allow(Stripe::Customer).to receive(:update).and_raise(error)

      post retailers_payment_methods_path(retailer_user.retailer, payment_method: 'anything')

      body = JSON.parse(response.body)

      expect(response.status).to eq(500)
      expect(body['data']).not_to be(nil)
    end

    it 'response with an error if stripe pops an exception when retrieving PaymentMethod' do

      error = Stripe::InvalidRequestError.new('s', {})
      allow(Stripe::PaymentMethod).to receive(:retrieve).and_raise(error)

      post retailers_payment_methods_path(retailer_user.retailer, payment_method: 'anything')

      body = JSON.parse(response.body)

      expect(response.status).to eq(500)
      expect(body['data']).not_to be(nil)
    end

    # Por urgencia de resolver el funcionamiento de las importaciones de customers,
    # se ha comentado esta prueba por conflictos con la gema activerecord-session_store.
    # PR: https://github.com/ThoughtCode/mercately/pull/657

    # it 'response with an error if when saving the payment method pops an exception' do
    #   allow_any_instance_of(PaymentMethod).to receive(:save).and_return(false)
    #   post retailers_payment_methods_path(retailer_user.retailer)

    #   body = JSON.parse(response.body)

    #   expect(response.status).to eq(500)
    #   expect(body['data']).not_to be(nil)
    # end
  end
end
