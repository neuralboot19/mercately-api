require 'rails_helper'
require 'vcr'

RSpec.describe MercadoLibre::Questions, vcr: true do
  subject(:questions_service) { described_class.new(retailer) }

  let(:retailer) { meli_retailer.retailer }
  let(:meli_retailer) { create(:meli_retailer) }
  let(:meli_customer) { create(:meli_customer) }
  let!(:customer) { create(:customer, retailer: retailer, meli_customer: meli_customer) }
  let!(:product) { create(:product, retailer: retailer, meli_product_id: 'MEC422883419') }

  describe '#import' do
    it 'saves the question' do
      VCR.use_cassette('questions/question') do
        expect { questions_service.import('6364208848') }.to change(Question, :count).by(1)
      end
    end
  end

  describe '#answer_question' do
    let(:question) { create(:question, customer: customer) }

    before do
      stub_const('Response', Struct.new(:status, :body))
      response = Response.new(201, '{"status": "success", "answer": "My answer"}')
      allow(Connection).to receive(:post_request)
        .with(anything, anything).and_return(response)
    end

    it 'sends a question for that order in ML' do
      response = questions_service.answer_question(question)
      expect(response.status).to eq 201
    end
  end

  describe '#import_inherited_questions' do
    it 'saves product\'s unanswered questions' do
      VCR.use_cassette('questions/inherited_questions') do
        expect { questions_service.import_inherited_questions(product) }.to change(Question, :count).by(8)
      end
    end
  end
end
