require 'rails_helper'

RSpec.describe AgentCustomer, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer_user) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:team_assignment).required(false) }
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

        context 'when is a Messenger customer' do
          before do
            customer.update(psid: '12345')
          end

          it 'will send the message with the customer full_name' do
            expect(Retailers::MobilePushNotificationJob).to receive(:perform_later)
              .with(
                [mobile_token.mobile_push_token],
                "Nuevo chat asignado - #{customer.full_names}",
                customer.id,
                'messenger'
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
                "Nuevo chat asignado - #{customer.phone}",
                customer.id,
                'messenger'
              )

            agent_customer.update(retailer_user_id: retailer_user2.id)
          end
        end

        context 'when is a whatsapp customer' do
          before do
            customer.update(ws_active: true)
          end

          it 'will send the message with the customer full_name' do
            expect(Retailers::MobilePushNotificationJob).to receive(:perform_later)
              .with(
                [mobile_token.mobile_push_token],
                "Nuevo chat asignado - #{customer.full_names}",
                customer.id,
                'whatsapp'
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
                "Nuevo chat asignado - #{customer.phone}",
                customer.id,
                'whatsapp'
              )

            agent_customer.update(retailer_user_id: retailer_user2.id)
          end
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

  describe '#free_spot_on_destroy' do
    let(:retailer) { create(:retailer, :gupshup_integrated) }
    let(:retailer_user) { create(:retailer_user, retailer: retailer) }
    let(:customer) { create(:customer, :messenger, agent: retailer_user) }

    context 'when the agent customer belongs to an assignment team' do
      let(:team_assignment) { create(:team_assignment, retailer: retailer) }
      let!(:agent_team) do
        create(:agent_team, retailer_user: retailer_user, team_assignment: team_assignment, assigned_amount: 2)
      end

      let!(:agent_customer) do
        create(:agent_customer, retailer_user: retailer_user, team_assignment: team_assignment, customer: customer)
      end

      context 'with the customer coming from a messenger chat' do
        let(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }
        let!(:facebook_message) { create(:facebook_message, customer: customer, facebook_retailer: facebook_retailer) }

        context 'with the chat unresolved' do
          it 'decreases by one the agent assignations on team' do
            expect {
              agent_customer.destroy
            }.to change{agent_team.reload.assigned_amount}.by(-1)
          end
        end

        context 'with the chat resolved' do
          it 'does not decrease the agent assignations on team' do
            agent_customer.customer.resolved!

            expect {
              agent_customer.destroy
            }.to change{agent_team.reload.assigned_amount}.by(0)
          end
        end
      end

      context 'with the customer coming from a whatsapp chat' do
        let!(:gupshup_whatsapp_message) do
          create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer)
        end

        context 'with the chat unresolved' do
          it 'decreases by one the agent assignations on team' do
            expect {
              agent_customer.destroy
            }.to change{agent_team.reload.assigned_amount}.by(-1)
          end
        end

        context 'with the chat resolved' do
          it 'does not decrease the agent assignations on team' do
            agent_customer.customer.resolved!

            expect {
              agent_customer.destroy
            }.to change{agent_team.reload.assigned_amount}.by(0)
          end
        end
      end
    end
  end

  describe '#free_spot_on_change' do
    let(:retailer) { create(:retailer, :gupshup_integrated) }
    let(:retailer_user) { create(:retailer_user, retailer: retailer) }
    let(:customer) { create(:customer, :messenger, agent: retailer_user) }
    let(:another_retailer_user) { create(:retailer_user, retailer: retailer) }

    context 'when the agent customer belongs to an assignment team' do
      let(:team_assignment) { create(:team_assignment, retailer: retailer) }
      let(:team_assignment2) { create(:team_assignment, retailer: retailer) }
      let!(:agent_team) do
        create(:agent_team, retailer_user: retailer_user, team_assignment: team_assignment, assigned_amount: 2)
      end
      let!(:agent_team2) do
        create(:agent_team, retailer_user: another_retailer_user, team_assignment: team_assignment2, assigned_amount: 0)
      end

      let!(:agent_customer) do
        create(:agent_customer, retailer_user: retailer_user, team_assignment: team_assignment, customer: customer)
      end

      context 'with the customer coming from a messenger chat' do
        let(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }
        let!(:facebook_message) { create(:facebook_message, customer: customer, facebook_retailer: facebook_retailer) }

        context 'with the chat unresolved' do
          it 'decreases by one the agent assignations on team' do
            expect {
              agent_customer.update(retailer_user_id: another_retailer_user.id, team_assignment_id: team_assignment2.id)
            }.to change{agent_team.reload.assigned_amount}.by(-1)
          end
        end

        context 'with the chat resolved' do
          it 'does not decrease the agent assignations on team' do
            agent_customer.customer.resolved!

            expect {
              agent_customer.update(retailer_user_id: another_retailer_user.id)
            }.to change{agent_team.reload.assigned_amount}.by(0)
          end
        end
      end

      context 'with the customer coming from a whatsapp chat' do
        let!(:gupshup_whatsapp_message) do
          create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer)
        end

        context 'with the chat unresolved' do
          it 'decreases by one the agent assignations on team' do
            expect {
              agent_customer.update(retailer_user_id: another_retailer_user.id, team_assignment_id: team_assignment2.id)
            }.to change{agent_team.reload.assigned_amount}.by(-1)
          end
        end

        context 'with the chat resolved' do
          it 'does not decrease the agent assignations on team' do
            agent_customer.customer.resolved!

            expect {
              agent_customer.update(retailer_user_id: another_retailer_user.id)
            }.to change{agent_team.reload.assigned_amount}.by(0)
          end
        end
      end
    end
  end
end
