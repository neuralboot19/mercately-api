require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(%i[pending success cancelled]) }
    it do
      is_expected.to define_enum_for(:merc_status).with_values(%i[
        confirmed
        payment_required
        payment_in_process
        partially_paid
        paid
        cancelled
        invalid_order
      ]).with_prefix(true)
    end
    it do
      is_expected.to define_enum_for(:feedback_reason).with_values(%i[
        SELLER_OUT_OF_STOCK
        SELLER_DIDNT_TRY_TO_CONTACT_BUYER
        BUYER_NOT_ENOUGH_MONEY
        BUYER_REGRETS
      ])
    end
    it { is_expected.to define_enum_for(:feedback_rating).with_values(%i[positive negative neutral]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to have_many(:order_items).inverse_of(:order).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:order_items) }
    it { is_expected.to have_many(:messages) }

    it { is_expected.to accept_nested_attributes_for(:order_items).allow_destroy(true) }
    it { is_expected.to accept_nested_attributes_for(:customer).allow_destroy(false) }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:feedback_message).is_at_most(160) }
  end
end
