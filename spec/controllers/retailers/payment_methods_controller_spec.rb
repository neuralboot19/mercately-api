require 'rails_helper'

RSpec.describe Retailers::PaymentMethodsController, type: :controller do
  let(:retailer_user) { create(:retailer_user, :with_retailer, first_name: '', last_name: '' ) }

  before do
    sign_in retailer_user
  end

  describe "GET #payment_methods" do
    describe '#delete' do
      let(:pms) { create_list(:payment_method, 3, retailer: retailer_user.retailer) }

      before do
        allow(Stripe::PaymentMethod).to receive(:detach).and_return(true)
      end

      it 'deletes a payment method and creates a notice message' do
        delete :destroy, params: { slug: retailer_user.retailer.slug, id: pms.first.stripe_pm_id }

        expect(PaymentMethod.count).to eq(2)
        expect(flash[:notice]).to be_present
        expect(flash[:notice]).to eq('Método de pago eliminado con éxito.')
      end

      it 'does not delete and redirects back with a flash alert if not found' do
        pms
        expect(PaymentMethod.count).to eq(3)

        expect(
          delete :destroy, params: { slug: retailer_user.retailer.slug, id: 22222 }
        ).to redirect_to(retailers_payment_plans_path(retailer_user.retailer))

        expect(PaymentMethod.count).to eq(3)

        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to eq('Método de pago no encontrado.')
      end
    end
  end
end
