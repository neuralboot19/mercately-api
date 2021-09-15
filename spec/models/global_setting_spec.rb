require 'rails_helper'

RSpec.describe GlobalSetting, type: :model do
  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:setting_key)}
    it { is_expected.to validate_presence_of(:setting_key) }
    it { is_expected.to validate_presence_of(:value) }
  end
end