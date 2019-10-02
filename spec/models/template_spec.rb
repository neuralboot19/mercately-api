require 'rails_helper'

RSpec.describe Template, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:answer) }
  end
end
