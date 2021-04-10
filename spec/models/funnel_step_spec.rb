require 'rails_helper'

RSpec.describe FunnelStep, type: :model do
  let(:retailer) { create(:retailer) }
  let(:funnel) { create(:funnel, retailer: retailer) }

  let(:f_step_1) { create(:funnel_step, funnel: funnel) }
  let(:f_step_2) { create(:funnel_step, funnel: funnel) }

  describe 'associations' do
    it { is_expected.to belong_to(:funnel) }
    it { is_expected.to have_many(:deals) }
  end
end
