require 'rails_helper'

RSpec.describe OrderHelper, type: :helper do
  let(:order) { build(:order) }

  describe '#disabled_statuses' do
    context 'when the order is a new record' do
      it 'returns an array with cancelled status' do
        @order = order
        expect(helper.disabled_statuses).to eq(%w[cancelled])
      end
    end

    context 'when the order status is pending' do
      it 'returns an empty array' do
        @order = order
        @order.save
        expect(helper.disabled_statuses).to eq([])
      end
    end

    context 'when the order status is cancelled' do
      it 'returns an array with all the statuses' do
        @order = order
        @order.update(status: 'cancelled')
        expect(helper.disabled_statuses).to eq(%w[pending success cancelled])
      end
    end

    context 'when the order status is success' do
      it 'returns an array with pending status' do
        @order = order
        @order.update(status: 'success')
        expect(helper.disabled_statuses).to eq(%w[pending])
      end
    end
  end
end
