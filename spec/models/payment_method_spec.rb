require 'rails_helper'

RSpec.describe PaymentMethod, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:stripe_pm_id) }
    it { is_expected.to validate_presence_of(:retailer) }
    it { is_expected.to validate_presence_of(:payment_type) }
    it { is_expected.to validate_presence_of(:payment_payload) }
  end
end
