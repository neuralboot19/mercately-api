require 'rails_helper'

RSpec.describe PaymentezCreditCard, type: :model do
  subject(:paymentez_credit_card) { create(:paymentez_credit_card, :main_card) }
  let!(:admin) { create(:retailer_user, :admin, retailer: subject.retailer) }
  let!(:payment_plan) { create(:payment_plan, retailer: subject.retailer) }

  describe '#create_transaction' do
    it 'returns true if plan is free' do
      payment_plan.update(plan: 'free')
      expect(subject.create_transaction).to eq(true)
    end

    it 'returns true if price is zero' do
      payment_plan.update(price: 0)
      expect(subject.create_transaction).to eq(true)
    end

    context 'when transacion responses unsuccessfully' do
      before do
        allow_any_instance_of(PaymentezTransaction).to receive(:debit_with_token).and_return(status: 500)
        payment_plan.update(price: 20, plan: 1)
      end

      it 'returns false if response status is not 200' do
        expect(subject.create_transaction).to eq(false)
      end
    end

    context 'when transacion responses successfully' do
      let(:success_transaction_response) {
        Faraday::Response.new(
          status: 200,
          body: '{'\
            '"transaction": {' \
              '"status": "success",' \
              '"payment_date": "' + Time.now.to_s + '"'\
            '}' \
          '}'
        )
      }

      before do
        allow_any_instance_of(PaymentezTransaction).to receive(:request_debit).and_return(success_transaction_response)
        payment_plan.update(price: 20, plan: 1)
      end

      it 'debits plan from the credit card' do
        expect {
          subject.create_transaction
        }.to change(PaymentezTransaction, :count).by(1)
      end

      it 'returns true' do
        expect(subject.create_transaction).to eq(true)
      end
    end
  end
end
