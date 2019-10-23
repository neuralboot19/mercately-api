require 'rails_helper'
require 'vcr'

RSpec.describe MercadoLibre::Orders, vcr: true do
  subject(:orders_service) { described_class.new(retailer) }

  let(:retailer) { meli_retailer.retailer }
  let(:meli_retailer) { create(:meli_retailer) }

  describe '#import' do
    it 'imports the order' do
      VCR.use_cassette('orders/order') do
        expect { orders_service.import('2155642803') }.to change(Order, :count).by(1)
      end
    end
  end

  describe '#push_feedback' do
    let(:customer) { create(:customer, retailer: retailer) }
    let(:order) { create(:order, customer: customer) }

    before do
      Response = Struct.new(:status, :body)
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
