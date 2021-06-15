require 'rails_helper'

RSpec.describe Funnel, type: :model do
  let(:retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let(:funnel) { create(:funnel, retailer: retailer) }

  let(:f_step_1) { create(:funnel_step, funnel: funnel) }
  let(:f_step_2) { create(:funnel_step, funnel: funnel) }

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to have_many(:funnel_steps) }
  end

  describe 'validations' do
    describe 'validate presence of' do
      it { is_expected.to validate_presence_of(:name) }
    end
  end

  describe 'update_colomn_order' do
    it 'sets right order' do
      funnel.update_column_order([f_step_2.web_id, f_step_1.web_id ])
      expect(funnel.funnel_steps).to eq([f_step_2, f_step_1])
    end
  end
end
