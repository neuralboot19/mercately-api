require 'rails_helper'

RSpec.describe AgentCustomer, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer_user) }
    it { is_expected.to belong_to(:customer) }
  end

  describe '#send_push_notifications' do
    let(:retailer) { create(:retailer) }
    let(:retailer_user) { create(:retailer_user, retailer: retailer) }
    let(:customer) { create(:customer, agent: retailer_user) }

    it 'will send push notifications if retailer user changed' do
      ActiveJob::Base.queue_adapter = :test

      agent_customer = create(
        :agent_customer,
        retailer_user: retailer_user,
        customer: customer
      )
      retailer_user2 = create(:retailer_user, retailer: retailer)

      expect {
        agent_customer.update(retailer_user_id: retailer_user2.id)
      }.to have_enqueued_job(Retailers::MobilePushNotificationJob)
    end
  end
end
