require 'rails_helper'

RSpec.describe Question, type: :model do
  subject(:question) { build(:question, product: product) }

  let(:retailer) { create(:retailer) }
  let(:meli_retailer) { create(:meli_retailer, retailer: retailer) }
  let(:product) { create(:product, retailer: retailer) }

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
    let(:ml_question) { instance_double(MercadoLibre::Questions) }

    before do
      allow(ml_question).to receive(:answer_question)
        .with(anything).and_return('Question answered')
      allow(MercadoLibre::Questions).to receive(:new).with(question.product.retailer)
        .and_return(ml_question)
    end

    it 'calls ML answer question service' do
      question.product.retailer.meli_retailer = meli_retailer
      expect(question.send(:ml_answer_question)).not_to be_nil
    end
  end

  describe '#set_answered' do
    context 'when the answer is empty' do
      it 'before save does not update the answered attribute' do
        question.save
        expect(question.answered).to be false
      end
    end

    context 'when the answer is not empty' do
      let(:ml_question) { instance_double(MercadoLibre::Questions) }

      before do
        allow(ml_question).to receive(:answer_question)
          .with(anything).and_return('Question answered')
        allow(MercadoLibre::Questions).to receive(:new).with(question.product.retailer)
          .and_return(ml_question)
      end

      it 'before save updates the answered attribute' do
        question.product.retailer.meli_retailer = meli_retailer
        question.answer = 'Example answer'
        question.save
        expect(question.answered).to be true
      end
    end
  end

  describe '#generate_web_id' do
    it 'generates the web_id field to questions' do
      expect(question.web_id).to be_nil
      question.save
      expect(question.web_id).not_to be_nil
    end
  end

  describe '#to_param' do
    it 'returns the question web_id' do
      question.save
      expect(question.to_param).to eq(question.web_id)
    end
  end
end
