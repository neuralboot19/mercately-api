require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

RSpec.describe Retailers::RetailerChargeAlertJob, type: :job do
  describe '#perform_in' do
    let(:retailer) { create(:retailer) }
    let(:payment_plan) { create(:payment_plan, retailer: retailer) }
    let(:slack_notifier) { instance_double(Slack::Notifier) }

    before do
      allow(Slack::Notifier).to receive(:new).and_return(slack_notifier)
      allow(slack_notifier).to receive(:ping).and_return(true)
    end

    it 'enques the job' do
      expect(payment_plan.next_pay_date).to eq(nil)
      Retailers::RetailerChargeAlertJob.perform_in(2.seconds, payment_plan.id)
      expect(payment_plan.reload.next_pay_date).not_to eq(nil)
    end
  end
end
