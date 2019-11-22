require 'rails_helper'
require 'vcr'

RSpec.describe MercadoLibre::Orders, vcr: true do
  subject(:orders_service) { described_class.new(retailer) }

  let(:retailer) { meli_retailer.retailer }
  let(:meli_retailer) { create(:meli_retailer) }

  describe '#import' do
    context 'when the date of the order is lower than meli retailers creation date' do
      it 'does not import the order' do
        VCR.use_cassette('orders/order') do
          expect { orders_service.import('2155642803') }.to change(Order, :count).by(0)
        end
      end
    end

    context 'when the date of the order is greater than meli retailers creation date' do
      it 'imports the order' do
        meli_retailer.update(created_at: Time.now - 2.days)

        VCR.use_cassette('orders/order_imported') do
          expect { orders_service.import('2221214824') }.to change(Order, :count).by(1)
        end
      end
    end
  end

  describe '#push_feedback' do
    let(:customer) { create(:customer, retailer: retailer) }
    let(:order) { create(:order, customer: customer) }

    before do
      stub_const('Response', Struct.new(:status, :body))
      response = Response.new(201, status: 'success')
      allow(Connection).to receive(:post_request)
        .with(anything, anything).and_return(response)
    end

    it 'push the order\'s feedback to ML' do
      response = orders_service.push_feedback(order)
      expect(response.status).to eq 201
    end
  end
end
