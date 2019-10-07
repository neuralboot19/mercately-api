require 'rails_helper'

RSpec.describe MeliCustomer, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:customers) }
  end
end
