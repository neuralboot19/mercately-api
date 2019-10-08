require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  subject(:order_item) { build(:order_item) }

  describe 'associations' do
    it { is_expected.to belong_to(:order).inverse_of(:order_items) }
    it { is_expected.to belong_to(:product) }
    it { is_expected.to belong_to(:product_variation).required(false) }
  end

  describe 'delegates' do
    it { is_expected.to delegate_method(:meli_product_id).to(:product) }
  end

  describe '#subtotal' do
    it 'calculates the item quantity multilplied by unit price' do
      expect(order_item.subtotal).to eq(order_item.quantity * order_item.unit_price)
    end
  end
end
