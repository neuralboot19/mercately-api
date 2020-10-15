require 'rails_helper'

RSpec.describe 'PaymentezController', type: :request do
  let(:retailer_user) { create(:retailer_user, :with_retailer, first_name: '', last_name: '' ) }

  let(:faraday_debit_mock) {
    Faraday::Response.new(
      status: 200,
      body: '{
        "transaction": {
          "status": "success",
          "payment_date": "2020-08-04T15:38:23.350",
          "amount": 55.99,
          "authorization_code": "TEST00",
          "installments": 0,
          "dev_reference": "6",
          "message": "Response by mock",
          "carrier_code": "00",
          "id": "DF-23768",
          "status_detail": 3
        },
        "card": {
          "bin": "411111",
          "status": "valid",
          "token": "18273835264176777008",
          "expiry_year": "2024",
          "expiry_month": "4",
          "transaction_reference":
          "DF-23768",
          "type": "vi",
          "number": "1111",
          "origin": "Paymentez"
        }
      }'
    )
  }


  let(:card_token_mock) {
    {
      'status': 'valid',
      'token': '11113822264170000000',
      'expiry_year': '2024',
      'expiry_month': '4',
      'type': 'vi',
      'number': '1111',
    }
  }

  let(:purchasing_card_mock) {
    {
      'amount': '49.99',
      'plan': 'professional',
      'terms': 'true'
    }
  }

  before do
    sign_in retailer_user
  end

  describe 'POST #create' do
    context 'when is not purchasing a plan' do
      it 'creates a new card' do
        current_retailer = retailer_user.retailer

        post retailers_paymentez_index_path(
          current_retailer,
          cardToken: card_token_mock,
          holder_name: 'The Card Holder\'s name'
        )

        expect(response.status).to eq(200)

        body = JSON.parse(response.body)
        expect(body['notice']).to eq('Tarjeta agregada exitosamente')

        card = current_retailer.paymentez_credit_cards.first
        expect(card.token).to eq(card_token_mock[:token])
      end

      it 'not creates a new card if any error when saving' do
        allow_any_instance_of(PaymentezCreditCard).to receive(:save).and_return(false)

        current_retailer = retailer_user.retailer

        post retailers_paymentez_index_path(
          current_retailer,
          cardToken: card_token_mock,
          holder_name: 'The Card Holder\'s name'
        )

        expect(response.status).to eq(500)

        body = JSON.parse(response.body)
        expect(body['notice']).to eq('Error al agregar tarjeta')

        expect(PaymentezCreditCard.count).to eq(0)
      end
    end

    context 'when is purchasing a plan' do
      it 'activates the plan when no errors returned' do
        allow(PaymentezTransaction).to receive(:do_request).and_return(faraday_debit_mock)

        current_retailer = retailer_user.retailer
        current_retailer.payment_plan.update(status: 'inactive')

        post retailers_paymentez_index_path(
          current_retailer,
          cardToken: card_token_mock,
          holder_name: 'The Card Holder\'s name',
          card: purchasing_card_mock
        )

        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body['message']).to eq('Plan activado exitosamente')

        expect(current_retailer.reload.payment_plan.status).to eq('active')
      end

      it 'does not activates the plan if error occurs' do
        allow_any_instance_of(PaymentezCreditCard).to receive(:create_transaction_with_plan).and_return(false)

        current_retailer = retailer_user.retailer
        current_retailer.payment_plan.update(status: 'inactive')

        post retailers_paymentez_index_path(
          current_retailer,
          cardToken: card_token_mock,
          holder_name: 'The Card Holder\'s name',
          card: purchasing_card_mock
        )

        expect(response.status).to eq(500)
        body = JSON.parse(response.body)
        expect(body['message']).to eq('Error al activar plan')

        expect(current_retailer.reload.payment_plan.status).to eq('inactive')
      end
    end
  end

  describe 'POST #add_balance' do
    let(:credit_card) { create(:paymentez_credit_card, retailer: retailer_user.retailer) }

    let(:purchase_params) {
      {'amount': '25', 'cc_id': credit_card.id.to_s, terms: 'true'}
    }

    it 'adds whatsapp balance' do
      allow(PaymentezTransaction).to receive(:do_request).and_return(faraday_debit_mock)

      current_retailer = retailer_user.retailer
      current_retailer.update(ws_balance: 0)

      post add_balance_retailers_paymentez_index_path(
        current_retailer,
        card: purchase_params
      )

      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Saldo agregado exitosamente')

      expect(current_retailer.reload.ws_balance).to eq(25.0)
    end

    it 'not adds whatsapp balance if error occurs' do
      allow_any_instance_of(PaymentezCreditCard).to receive(:create_transaction_with_amount).and_return(false)

      current_retailer = retailer_user.retailer
      current_retailer.update(ws_balance: 0)

      post add_balance_retailers_paymentez_index_path(
        current_retailer,
        card: purchase_params
      )

      expect(response.status).to eq(500)
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Error al agregar saldo')

      expect(current_retailer.reload.ws_balance).to eq(0)
    end
  end

  describe 'POST #purchase_plan' do
    let(:credit_card) { create(:paymentez_credit_card, retailer: retailer_user.retailer) }

    let(:purchase_params) {
      {'amount': '25', 'cc_id': credit_card.id.to_s, terms: 'true', plan: 'professional'}
    }

    it 'activates the plan when no errors returned' do
      allow(PaymentezTransaction).to receive(:do_request).and_return(faraday_debit_mock)

      current_retailer = retailer_user.retailer
      current_retailer.payment_plan.update(status: 'inactive')

      post purchase_plan_retailers_paymentez_index_path(
        current_retailer,
        card: purchase_params
      )

      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Plan activado exitosamente')

      expect(current_retailer.reload.payment_plan.status).to eq('active')
    end

    it 'does not activates the plan if error occurs' do
      allow_any_instance_of(PaymentezCreditCard).to receive(:create_transaction_with_plan).and_return(false)

      current_retailer = retailer_user.retailer
      current_retailer.payment_plan.update(status: 'inactive')

      post purchase_plan_retailers_paymentez_index_path(
        current_retailer,
        card: purchase_params
      )

      expect(response.status).to eq(500)
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Error al activar plan')

      expect(current_retailer.reload.payment_plan.status).to eq('inactive')
    end

    it 'plan is not activated if not accept the terms' do
      purchase_params_mock_terms = {'amount': '25', 'cc_id': credit_card.id.to_s, terms: '', plan: 'professional'}

      allow_any_instance_of(PaymentezCreditCard).to receive(:create_transaction_with_plan).and_return(false)

      current_retailer = retailer_user.retailer
      current_retailer.payment_plan.update(status: 'active')

      post purchase_plan_retailers_paymentez_index_path(
        current_retailer,
        card: purchase_params_mock_terms
      )
      expect(flash[:notice]).to be_present
      expect(flash[:notice]).to match(/Usted debe aceptar los términos y condiciones/)
      expect(response.status).to eq(500)
      body = JSON.parse(response.body)
      expect(body['message']).to eq('Usted debe aceptar los términos y condiciones')

       expect(current_retailer.reload.payment_plan.status).to eq('active')
    end
  end
end
