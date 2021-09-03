require 'rails_helper'

RSpec.describe Retailers::MobilePushNotificationJob, type: :job do
  let(:mobile_token) { create(:mobile_token) }
  let(:body) { 'Text message' }
  let(:customer) { create(:customer) }
  let(:data) do
    {
      data: {
        title: customer.notification_info,
        body: body,
        customer_id: customer.id,
        type: 'message',
        channel: 'whatsapp'
      },
      priority: 'high',
      mutableContent: true,
      contentAvailable: true
    }
  end

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#perform_later' do
    it 'enques the job' do
      expect {
        Retailers::MobilePushNotificationJob.perform_later(
          [mobile_token.mobile_push_token], body, customer.id, 'whatsapp'
        )
      }.to have_enqueued_job
    end
  end

  describe '#perform_now' do
    it 'sends a push notification' do
      expect_any_instance_of(FCM).to receive(:send)
        .with([mobile_token.mobile_push_token], data)

      Retailers::MobilePushNotificationJob.perform_now(
        [mobile_token.mobile_push_token], body, customer.id, 'whatsapp'
      )
    end

    # Se comenta porque esto no esta hecho aun con la nueva gema.
    # it 'deletes the mobile token if exception pops' do
    #   allow_any_instance_of(Exponent::Push::Client).to receive(:send_messages).and_raise(Exponent::Push::UnknownError)

    #   Retailers::MobilePushNotificationJob.perform_now(
    #     [mobile_token.mobile_push_token], body, customer.id
    #   )

    #   expect(MobileToken.find_by_id(mobile_token.id)).to eq(nil)
    # end
  end
end
