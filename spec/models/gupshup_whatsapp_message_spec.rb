require 'rails_helper'

RSpec.describe GupshupWhatsappMessage, type: :model do
  before do
    allow_any_instance_of(Exponent::Push::Client).to receive(:send_messages).and_return(true)
  end

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:retailer_user).required(false) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:retailer) }
    it { is_expected.to validate_presence_of(:customer) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:direction) }
    it { is_expected.to validate_presence_of(:source) }
    it { is_expected.to validate_presence_of(:destination) }
    it { is_expected.to validate_presence_of(:channel) }
  end

  describe 'scopes' do
    let(:inbound) { create(:gupshup_whatsapp_message, :inbound, created_at: Time.now - 2.hours) }

    let(:inbound) { create(:gupshup_whatsapp_message, :inbound, created_at: Time.now - 2.hours) }
    let(:outbound) { create(:gupshup_whatsapp_message, :outbound, created_at: Time.now - 3.minutes) }

    let(:notification_message) { create(:gupshup_whatsapp_message, :notification, created_at: Time.now - 3.minutes) }
    let(:conversation_message) { create(:gupshup_whatsapp_message, :conversation, created_at: Time.now - 3.minutes) }

    it 'will return inbound messages' do
      inbound
      expect(described_class.inbound_messages.count).to eq(1)
    end

    it 'will return outbound messages' do
      outbound
      expect(described_class.outbound_messages.count).to eq(1)
    end

    it 'will return notification messages' do
      notification_message
      expect(described_class.notification_messages.count).to eq(1)
    end

    it 'will return conversation messages' do
      conversation_message
      expect(described_class.conversation_messages.count).to eq(1)
    end

    it 'will return messages by range' do
      inbound
      outbound
      notification_message
      conversation_message
      expect(described_class.range_between(Time.now - 1.hour, Time.now).count).to eq(3)
    end
  end

  context 'set message type' do
    let(:message) { build(:gupshup_whatsapp_message) }

    it 'is conversation after create if isHSM = false' do
      message.message_payload = { 'isHSM': 'false' }
      message.save!
      expect(message.message_type).to eq('conversation')
    end

    it 'is notification after create if isHSM = true' do
      message.message_payload = { 'isHSM': 'true' }
      message.save!
      expect(message.message_type).to eq('notification')
    end
  end

  context '#type' do
    it 'returns the message outbound payload type' do
      message = build(:gupshup_whatsapp_message)
      message.message_payload = { 'isHSM': 'false', 'type': 'text' }
      message.save!

      expect(message.type).to eq('text')
    end

    it 'returns the message inbound payload type' do
      message = build(:gupshup_whatsapp_message)
      message.message_payload = { 'payload': { 'type': 'document' } }
      message.save!

      expect(message.type).to eq('document')
    end
  end

  describe '#send_welcome_message' do
    let(:set_gupshup_messages_service) { instance_double(Whatsapp::Gupshup::V1::Outbound::Msg) }

    before do
      allow(set_gupshup_messages_service).to receive(:send_message)
        .and_return('Sent')
      allow(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:new)
        .and_return(set_gupshup_messages_service)
    end

    context 'when the retailer does not have an active welcome message configured' do
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_welcome_message)).to be nil
      end
    end

    context 'when the customer does not text for the first time' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_welcome_message)).to be nil
      end
    end

    context 'when the message is not inbound' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:gupshup_whatsapp_message, :outbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_welcome_message)).to be nil
      end
    end

    context 'when all conditions are present' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: customer.retailer)
      end

      it 'sends the message' do
        expect(message.send(:send_welcome_message)).to eq('Sent')
      end
    end
  end

  describe '#send_inactive_message' do
    let(:set_gupshup_messages_service) { instance_double(Whatsapp::Gupshup::V1::Outbound::Msg) }

    before do
      allow(set_gupshup_messages_service).to receive(:send_message)
        .and_return('Sent')
      allow(Whatsapp::Gupshup::V1::Outbound::Msg).to receive(:new)
        .and_return(set_gupshup_messages_service)
    end

    context 'when the retailer does not have an inactive message configured' do
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the customer does not have a prior message sent' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the message is not inbound' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      let(:message) do
        create(:gupshup_whatsapp_message, :outbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the created time of the prior message is not passed yet' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer, created_at:
          Time.now - 11.hours)
      end

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when all conditions are present' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer, created_at:
          Time.now - 13.hours)
      end

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: customer.retailer)
      end

      it 'sends the message' do
        expect(message.send(:send_inactive_message)).to eq('Sent')
      end
    end
  end

  describe '#apply_cost' do
    let(:retailer) { create(:retailer, :gupshup_integrated) }

    context 'when the message status is not error' do
      let(:message) { build(:gupshup_whatsapp_message, retailer: retailer) }

      context 'when the message cost is zero' do
        it 'assigns the retailer conversation/notification cost to the message' do
          expect(message.cost).to be nil
          message.save
          expect(message.reload.cost).to eq(retailer.send("ws_#{message.message_type}_cost"))
        end
      end

      context 'when the message cost is not zero' do
        it 'does not change the message cost' do
          expect(message.cost).to be nil
          message.cost = 0.05
          message.save
          expect(message.reload.cost).to eq(0.05)
        end
      end
    end

    context 'when the message status is error' do
      let(:message) do
        build(:gupshup_whatsapp_message, retailer: retailer, status: 'error', cost: 0.05)
      end

      context 'when the message cost is not zero' do
        it 'sets the message cost to zero' do
          expect(message.cost).to eq(0.05)
          message.save
          expect(message.reload.cost).to eq(0)
        end
      end

      context 'when the message cost is zero' do
        it 'does not change the message cost' do
          message.cost = 0
          expect(message.cost).to eq(0)
          message.save
          expect(message.reload.cost).to eq(0)
        end
      end
    end
  end

  describe '#send_push_notifications' do
    let(:mobile_token) { create(:mobile_token) }
    let(:retailer) { mobile_token.retailer_user.retailer }
    let(:customer) { create(:customer, retailer: retailer) }

    it 'will send push notifications' do
      ActiveJob::Base.queue_adapter = :test

      expect {
        create(:gupshup_whatsapp_message, :inbound, customer: customer)
      }.to have_enqueued_job(Retailers::MobilePushNotificationJob)
    end
  end

  describe '#assign_agent' do
    context 'when the retailer has assignment teams permission' do
      let(:retailer) { create(:retailer, :gupshup_integrated, :with_team_assignment) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }
      let(:another_retailer_user) { create(:retailer_user, retailer: retailer) }
      let(:customer) { create(:customer, retailer: retailer) }
      let(:customer2) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer)
      end

      context 'when the message is inbound' do
        context 'with an agent already assigned' do
          let!(:agent_customer) { create(:agent_customer, customer: customer, retailer_user: retailer_user) }

          it 'returns nil' do
            expect(message.send(:assign_agent)).to be_nil
          end
        end

        context 'with the chat already answered by agent' do
          let!(:outbound_message) do
            create(:gupshup_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
              retailer_user)
          end

          it 'returns nil' do
            expect(message.send(:assign_agent)).to be_nil
          end
        end

        context 'when the retailer does not have a default team assignment created' do
          it 'returns nil' do
            expect(message.send(:assign_agent)).to be_nil
          end
        end

        context 'when the retailer does not have a default team assignment activated' do
          let!(:default_team) { create(:team_assignment, retailer: retailer, active_assignment: false) }

          it 'returns nil' do
            expect(message.send(:assign_agent)).to be_nil
          end
        end

        context 'when there is not any agent with free spots to assign' do
          let(:default_team) { create(:team_assignment, :assigned_default, retailer: retailer) }
          let!(:agent_team1) do
            create(:agent_team, :activated, team_assignment: default_team, retailer_user: retailer_user,
              max_assignments: 2, assigned_amount: 2)
          end

          let!(:agent_team2) do
            create(:agent_team, :activated, team_assignment: default_team, retailer_user: another_retailer_user,
              max_assignments: 4, assigned_amount: 4)
          end

          it 'does not assign an agent to the customer' do
            expect {
              create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer)
            }.to change(AgentCustomer, :count).by(0)
          end
        end

        context 'when there is at least one agent with free spots to assign' do
          let(:default_team) { create(:team_assignment, :assigned_default, retailer: retailer) }
          let!(:agent_team1) do
            create(:agent_team, :activated, team_assignment: default_team, retailer_user: retailer_user,
              max_assignments: 2, assigned_amount: 2)
          end

          let!(:agent_team2) do
            create(:agent_team, :activated, team_assignment: default_team, retailer_user: another_retailer_user,
              max_assignments: 4, assigned_amount: 3)
          end

          it 'assigns an agent to the customer' do
            expect {
              create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer)
            }.to change(AgentCustomer, :count).by(1)
          end
        end

        context 'when there is more than one agent with free spots to assign' do
          let(:default_team) { create(:team_assignment, :assigned_default, retailer: retailer) }
          let(:agent_team1) do
            create(:agent_team, :activated, team_assignment: default_team, retailer_user: retailer_user,
              max_assignments: 2, assigned_amount: 0)
          end

          let(:agent_team2) do
            create(:agent_team, :activated, team_assignment: default_team, retailer_user: another_retailer_user,
              max_assignments: 4, assigned_amount: 0)
          end

          it 'assigns the agent with less assignments to the customer and so on' do
            agent_team1
            agent_team2

            expect {
              create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer)
            }.to change(AgentCustomer, :count).by(1)

            last = AgentCustomer.last
            expect(agent_team1.retailer_user_id).to eq(last.retailer_user_id)
            expect(last.team_assignment_id).to eq(default_team.id)
            expect(agent_team1.reload.assigned_amount).to eq(1)

            expect {
              create(:gupshup_whatsapp_message, :inbound, customer: customer2, retailer: retailer)
            }.to change(AgentCustomer, :count).by(1)

            last = AgentCustomer.last
            expect(agent_team2.retailer_user_id).to eq(last.retailer_user_id)
            expect(last.team_assignment_id).to eq(default_team.id)
            expect(agent_team2.reload.assigned_amount).to eq(1)
          end
        end
      end

      context 'when the message is outbound' do
        let!(:inbound_message) do
          create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer)
        end

        let(:outbound_message) do
          create(:gupshup_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
            retailer_user)
        end

        context 'when the message does not come from an agent' do
          let(:not_from_agent) do
            create(:gupshup_whatsapp_message, :outbound, customer: customer, retailer: retailer)
          end

          it 'returns nil' do
            expect(not_from_agent.send(:assign_agent)).to be_nil
          end
        end

        context 'when the customer does not have an agent assigned' do
          it 'returns nil' do
            expect(outbound_message.send(:assign_agent)).to be_nil
          end
        end

        context 'when the agent assigned to the customer is not from a team' do
          let!(:agent_customer) { create(:agent_customer, customer: customer, retailer_user: retailer_user) }

          it 'returns nil' do
            expect(outbound_message.send(:assign_agent)).to be_nil
          end
        end

        context 'when the message is not the first one sent to the customer' do
          let(:default_team) { create(:team_assignment, :assigned_default, retailer: retailer) }
          let!(:agent_team) do
            create(:agent_team, :activated, team_assignment: default_team, retailer_user: retailer_user,
              max_assignments: 2, assigned_amount: 0)
          end

          let!(:agent_customer) do
            create(:agent_customer, customer: customer, retailer_user: retailer_user, team_assignment: default_team)
          end

          let!(:other_outbound) do
            create(:gupshup_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
              retailer_user)
          end

          it 'returns nil' do
            expect(outbound_message.send(:assign_agent)).to be_nil
          end
        end

        context 'when the message is the first one sent to the customer' do
          let(:default_team) { create(:team_assignment, :assigned_default, retailer: retailer) }
          let!(:agent_team) do
            create(:agent_team, :activated, team_assignment: default_team, retailer_user: retailer_user,
              max_assignments: 2, assigned_amount: 1)
          end

          let!(:agent_customer) do
            create(:agent_customer, customer: customer, retailer_user: retailer_user, team_assignment: default_team)
          end

          it 'decreases by one the assigned amount of the agent team' do
            expect(agent_team.assigned_amount).to eq(1)

            create(:gupshup_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
              retailer_user)

            expect(agent_team.reload.assigned_amount).to eq(0)
          end
        end
      end
    end

    context 'when the retailer does not have assignment teams permission' do
      let(:retailer) { create(:retailer, :gupshup_integrated) }
      let(:message) { create(:gupshup_whatsapp_message, retailer: retailer) }

      it 'returns nil' do
        expect(message.send(:assign_agent)).to be_nil
      end
    end
  end
end
