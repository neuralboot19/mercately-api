require 'rails_helper'

RSpec.describe AgentNotification, type: :model do
  let(:retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let(:customer) { create(:customer, retailer: retailer) }
  let(:agent_notification) do
    create(
      :agent_notification,
      customer: customer,
      retailer_user: retailer_user
    )
  end

  describe 'associations' do
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:retailer_user) }
  end

  describe 'validations' do
    describe 'validate presence of' do
      it { is_expected.to validate_presence_of(:customer) }
      it { is_expected.to validate_presence_of(:retailer_user) }
    end
  end

  describe 'default values' do
    it 'sets default status as unread' do
      expect(agent_notification.status).to eq('unread')
    end
  end

  describe '#read!' do
    it 'marks agent notification as read' do
      agent_notification.read!
      expect(agent_notification.status).to eq('read')
    end
  end
end
