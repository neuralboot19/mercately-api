require 'rails_helper'

RSpec.describe Retailers::MobilePushNotificationJob, type: :job do
  let(:mobile_token) { create(:mobile_token) }
  let(:body) { 'Text message' }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#perform_later' do
    it 'enques the job' do
      expect {
        Retailers::MobilePushNotificationJob.perform_later(
          [mobile_token.mobile_push_token], body
        )
      }.to have_enqueued_job
    end
  end

  describe '#perform_now' do
    it 'sends a push notification' do
      expect_any_instance_of(Exponent::Push::Client).to receive(:send_messages).
        with([{body: body, sound: 'default', to: mobile_token.mobile_push_token}])

      Retailers::MobilePushNotificationJob.perform_now(
        [mobile_token.mobile_push_token], body
      )
    end
  end
end
