require 'rails_helper'

RSpec.describe Retailers::PaymentezController, type: :controller do
  let(:retailer_user) { create(:retailer_user, :with_retailer, first_name: '', last_name: '' ) }
  let(:credit_card) { create(:paymentez_credit_card, retailer: retailer_user.retailer) }
  let(:faraday_delete_mock) {
    Faraday::Response.new(
      status: 200,
      body: '{"message": "card deleted"}'
    )
  }

  before do
    sign_in retailer_user
  end

  describe '#delete' do
    context 'when only one card' do
      it 'deletes a payment method and creates a notice message' do
        allow(PaymentezCreditCard).to receive(:do_request).and_return(faraday_delete_mock)
        delete :destroy, params: { slug: retailer_user.retailer.slug, id: credit_card.id }

        expect(PaymentezCreditCard.count).to eq(1)
      end
    end

    context 'when have multiple cards' do
      let!(:credit_card_2) { create(:paymentez_credit_card, retailer: retailer_user.retailer) }

      it 'deletes a payment method and creates a notice message' do
        allow(PaymentezCreditCard).to receive(:do_request).and_return(faraday_delete_mock)
        delete :destroy, params: { slug: retailer_user.retailer.slug, id: credit_card.id }

        expect(PaymentezCreditCard.count).to eq(1)
        expect(flash[:notice]).to be_present
        expect(flash[:notice]).to eq('Tarjeta eliminada satisfactoriamente.')
      end
    end

    it 'does not delete and redirects back with a flash alert if not found' do
      credit_card
      expect(PaymentezCreditCard.count).to eq(1)

      expect(
        delete :destroy, params: { slug: retailer_user.retailer.slug, id: 22222 }
      ).to redirect_to(retailers_payment_plans_path(retailer_user.retailer))

      expect(PaymentezCreditCard.count).to eq(1)

      expect(flash[:notice]).to be_present
      expect(flash[:notice]).to eq('Error al eliminar tarjeta.')
    end
  end
end
