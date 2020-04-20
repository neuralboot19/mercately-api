require 'rails_helper'

RSpec.describe TopUp, type: :model do
  subject(:top_up) { build(:top_up) }

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:retailer) }
    it { is_expected.to validate_presence_of(:amount) }
  end

  it 'will update the retailer ws_balance after create' do
    retailer_balance = subject.retailer.ws_balance
    subject.save
    expect(subject.retailer.ws_balance).to eq(subject.amount + retailer_balance)
  end
end
