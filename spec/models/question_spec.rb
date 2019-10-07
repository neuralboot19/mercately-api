require 'rails_helper'

RSpec.describe Question, type: :model do
  let(:retailer) { create(:retailer) }
  let(:meli_retailer) { create(:meli_retailer, retailer: retailer) }
  let(:product) { create(:product, retailer: retailer) }
  let(:question) { build(:question, product: product) }

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(%i[ANSWERED UNANSWERED CLOSED_UNANSWERED UNDER_REVIEW]) }
    it { is_expected.to define_enum_for(:answer_status).with_values(%i[ACTIVE DISABLED]) }
    it { is_expected.to define_enum_for(:meli_question_type).with_values(%w[from_order from_product]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:product) }
    it { is_expected.to belong_to(:customer) }
  end

  describe 'delegates' do
    it { is_expected.to delegate_method(:retailer).to(:product) }
  end

  describe '.check_unique_question_meli_id' do
    context 'when meli_id does not exist yet' do
      it 'finds that meli_id is not duplicated' do
        expect(described_class.check_unique_question_meli_id(question.meli_id)).to be false
      end
    end

    context 'when meli_id already exists' do
      it 'finds that meli_id is duplicated' do
        question.save
        expect(described_class.check_unique_question_meli_id(question.meli_id)).to be true
      end
    end
  end

  describe '#ml_answer_question' do
    it 'calls ML answer question service' do
      question.product.retailer.meli_retailer = meli_retailer
      expect(question.send(:ml_answer_question)).not_to be_nil
    end
  end
end
