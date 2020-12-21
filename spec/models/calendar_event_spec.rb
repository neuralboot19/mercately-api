require 'rails_helper'

RSpec.describe CalendarEvent, type: :model do
  subject { create(:calendar_event) }

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:retailer_user) }
  end

  describe '#calc_remember_at' do
    it 'sets the remember_at field' do
      expect(subject.remember_at).not_to be nil
    end
  end
end
