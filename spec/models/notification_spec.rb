require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:retailer) { create(:retailer)}
  let(:retailer_user) { create(:retailer_user, retailer: retailer)}

  subject(:notification) { build(:notifications) }

  describe 'associations' do
    it { is_expected.to have_many(:retailer_user_notifications) }
    it { is_expected.to have_many(:retailer_users).through(:retailer_user_notifications) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe '#min_visible_until' do
    it 'validates #visible_until is greater than Time.now' do
      notification.visible_until = 1.day.ago
      expect(notification.save).to be false
      notification.visible_until = 1.day.from_now
      expect(notification.save).to be true
    end
  end

  describe '#template_body' do
    it 'replaces macros with data' do
      notification.body = '%retailer%, %first_name%, %last_name%'
      expect(notification.template_body(retailer, retailer_user)).to eq "#{retailer_user.retailer.name}, #{retailer_user.first_name}, #{retailer_user.last_name}"
    end
  end
end
