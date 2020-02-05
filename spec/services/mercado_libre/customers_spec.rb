require 'rails_helper'
require 'vcr'

RSpec.describe MercadoLibre::Customers, vcr: true do
  subject(:customers_service) { described_class.new(retailer) }

  let(:retailer) { meli_retailer.retailer }
  let(:meli_retailer) { create(:meli_retailer) }

  describe '#import' do
    it 'imports the customer' do
      VCR.use_cassette('customers/customer') do
        expect { customers_service.import('445351893') }.to change(Customer, :count).by(1)
      end
    end

    context 'when it comes from an order' do
      subject(:customers_service) { described_class.new(retailer, order_params) }

      let(:order_params) { attributes_for(:customer, retailer: retailer).transform_keys(&:to_s) }

      it 'imports additional information' do
        VCR.use_cassette('customers/customer') do
          expect { customers_service.import('445351893') }.to change(Customer, :count).by(1)
          customer = MeliCustomer.find_by(meli_user_id: '445351893').customers.last
          expect(customer.full_names).not_to be_nil
        end
      end
    end
  end
end
