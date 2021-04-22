require 'rails_helper'

RSpec.describe DemoRequestLead, type: :model do
  subject(:demo_request_lead) { create(:demo_request_lead) }

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(%i[pending scheduled done cancelled]) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:company) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_presence_of(:phone) }
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_presence_of(:problem_to_resolve) }
  end

  describe '#format_phone_number' do
    it 'gives format to the phone' do
      subject.country = 'EC'
      subject.phone = '123456789'
      expect(subject.send(:format_phone_number)).to eq('+593123456789')
    end
  end
end
