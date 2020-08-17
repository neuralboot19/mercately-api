require 'rails_helper'

RSpec.describe AgentCustomer, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer_user) }
    it { is_expected.to belong_to(:customer) }
  end

  describe '#send_push_notifications' do
    let(:retailer) { create(:retailer) }
    let(:retailer_user) { create(:retailer_user, retailer: retailer) }
    let(:retailer_user2) { create(:retailer_user, retailer: retailer) }
    let(:customer) { create(:customer) }
    let(:agent_customer) do
      create(
        :agent_customer,
        retailer_user: retailer_user,
        customer: customer
      )
    end

    before do
      ActiveJob::Base.queue_adapter = :test
    end

    describe 'when retailer user changed' do
      context 'when is a mobile app user' do
        let(:customer2) { create(:customer, retailer: retailer) }
        let!(:mobile_token) { create(:mobile_token, retailer_user: retailer_user2) }

        it 'will enqueue the job if creating' do
          create(:mobile_token, retailer_user: retailer_user)
          expect do
            create(
              :agent_customer,
              retailer_user: retailer_user,
              customer: customer2
            )
          end.to have_enqueued_job(Retailers::MobilePushNotificationJob)
        end


        it 'will enqueue the job if updating' do
          expect do
            agent_customer.update(retailer_user_id: retailer_user2.id)
          end.to have_enqueued_job(Retailers::MobilePushNotificationJob)
        end

        it 'will send the message with the customer full_name' do
          expect(Retailers::MobilePushNotificationJob).to receive(:perform_later)
            .with(
              [mobile_token.mobile_push_token],
              "Nuevo chat asignado - #{customer.full_names}"
            )

          agent_customer.update(retailer_user_id: retailer_user2.id)
        end

        it 'will send the message with the customer phone when no first/last name' do
          customer.first_name = nil
          customer.last_name = nil
          customer.save!

          expect(Retailers::MobilePushNotificationJob).to receive(:perform_later)
            .with(
              [mobile_token.mobile_push_token],
              "Nuevo chat asignado - #{customer.phone}"
            )

          agent_customer.update(retailer_user_id: retailer_user2.id)
        end
      end

      it 'will not send push notifications if is not a mobile app user' do
        expect do
          agent_customer.update(retailer_user_id: retailer_user2.id)
        end.not_to have_enqueued_job(Retailers::MobilePushNotificationJob)
      end
    end

    it 'will not send push notifications when retailer user not changed' do
      expect do
        agent_customer.update(retailer_user_id: retailer_user.id)
      end.not_to have_enqueued_job(Retailers::MobilePushNotificationJob)
    end
  end
end
