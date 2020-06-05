require 'rails_helper'

RSpec.describe CustomerTag, type: :model do
  subject(:customer_tag) { create(:customer_tag) }

  describe 'associations' do
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:tag) }
  end
end
