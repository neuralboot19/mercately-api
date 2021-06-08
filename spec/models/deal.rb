require 'rails_helper'

RSpec.describe Deal, type: :model do
  let(:retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let(:funnel) { create(:funnel, retailer: retailer) }
  let(:f_step_1) { create(:funnel_step, funnel: funnel) }

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:funnel_step) }
    it { is_expected.to belong_to(:customer).optional }
  end

  describe 'validations' do
    describe 'validate presence of' do
      it { is_expected.to validate_presence_of(:name) }
    end
  end
end


