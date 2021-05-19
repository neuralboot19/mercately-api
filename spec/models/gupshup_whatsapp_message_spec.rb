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

  describe 'bots execution' do
    let(:chat_bot_option) { create(:chat_bot_option) }

    let(:chat_bot_option_a) do
      create(:chat_bot_option, parent: chat_bot_option, position: 1, text: 'Cuentame más')
    end

    let(:chat_bot_option_b) do
      create(:chat_bot_option, parent: chat_bot_option, position: 2, text: 'Quiero Volver atrás')
    end

    let(:chat_bot_option_c) do
      create(:chat_bot_option, parent: chat_bot_option, position: 3, text: 'Volver volver atrás')
    end

    let(:chat_bot) do
      create(:chat_bot, :bot_enabled, :with_accented_trigger, :for_whatsapp, chat_bot_options:
        [chat_bot_option, chat_bot_option_a, chat_bot_option_b, chat_bot_option_c])
    end

    let(:retailer) { create(:retailer, :with_chat_bots, :gupshup_integrated, chat_bots: [chat_bot]) }
    let(:customer) { create(:customer, :able_to_start_bots, retailer: retailer) }
    let(:message) { build(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer) }
    let(:answer_message) { build(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer) }

    context 'when the customer has not activated the chat bot yet' do
      it 'triggers a chat bot ignoring accent marks' do
        message.save!
        expect(customer.active_bot).to eq(true)
        expect(customer.chat_bot_option_id).to eq(chat_bot_option.id)
      end

      it 'selects an option by matching whole sentence ignoring accent marks' do
        message.save!
        answer_message.message_payload = {'type': 'text', 'text': 'quiero volver atras' }
        answer_message.save!
        expect(customer.chat_bot_option_id).to eq(chat_bot_option_b.id)
      end

      it 'rejects selection and stays in last valid option if more than one option has the same ranking' do
        message.save!
        answer_message.message_payload = {'type': 'text', 'text': 'atras' }
        answer_message.save!
        expect(customer.chat_bot_option_id).to be nil
      end

      it 'selects an option by matches count ranking' do
        message.save!
        answer_message.message_payload = {'type': 'text', 'text': 'atras volver' }
        answer_message.save!
        expect(customer.chat_bot_option_id).to eq(chat_bot_option_c.id)
      end

      context 'chat bot options with media' do
        let(:root_option) { create(:chat_bot_option, text: 'Root node') }
        let(:chat_bot_option_image) {create(:chat_bot_option,  :with_image_file, parent: root_option, position: 1, text: '1 Image')}
        let(:chat_bot_option_pdf) {create(:chat_bot_option, :with_pdf_file, parent: root_option, position: 2, text: '2 PDF')}
        let(:chat_bot) do
          create(:chat_bot, :bot_enabled, :with_accented_trigger, :for_whatsapp,
            chat_bot_options: [root_option, chat_bot_option_image, chat_bot_option_pdf],
            trigger: 'Estoy interesado en Mercately')
        end

        let(:retailer) { create(:retailer, :gupshup_integrated, :with_chat_bots, chat_bots: [chat_bot]) }
        let(:customer) { create(:customer, :able_to_start_bots, retailer: retailer) }
        let(:message) do
          build(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer,
            message_payload: {'type': 'text', 'text': 'Estoy interesado en Mercately'})
        end

        let(:answer_message) do
          build(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer)
        end

        it 'selects a chat bot option with image' do
          message.save!
          answer_message.message_payload = {'type': 'text', 'text': '1' }
          answer_message.save!
          expect(customer.chat_bot_option_id).to eq(chat_bot_option_image.id)
        end

        it 'selects a chat bot option with pdf' do
          message.save!
          answer_message.message_payload = {'type': 'text', 'text': '2' }
          answer_message.save!
          expect(customer.chat_bot_option_id).to eq(chat_bot_option_pdf.id)
        end
      end
    end

    context 'when the customer has already activated the chat bot' do
      let(:customer) { create(:customer, retailer: retailer) }
      let(:message) { build(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer) }

      context 'when the chat bot does not have reactivation time and customer is not allowed to activate bots' do
        let!(:chat_bot_customer) { create(:chat_bot_customer, customer: customer, chat_bot: chat_bot) }

        it 'does not activate the chat bot' do
          message.message_payload = { 'type': 'text', 'text': 'hola test' }
          message.save
          expect(customer.active_bot).to be false
          expect(customer.chat_bot_option_id).to be_nil
        end
      end

      context 'when customer is allowed to activate bots' do
        let!(:chat_bot_customer) { create(:chat_bot_customer, customer: customer, chat_bot: chat_bot) }

        before do
          customer.activate_chat_bot!
        end

        it 'activates the chat bot' do
          message.message_payload = { 'type': 'text', 'text': 'hola test' }
          message.save
          expect(customer.active_bot).to be true
          expect(customer.chat_bot_option_id).to eq(chat_bot_option.id)
        end
      end

      context 'when the chat bot has reactivation time' do
        context 'when the message is received outside the reactivation time' do
          let(:answer_message) { build(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer) }

          let!(:prev_message) do
            create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer, created_at:
              Time.now - 5.hours)
          end

          let!(:chat_bot_customer) do
            create(:chat_bot_customer, customer: customer, chat_bot: chat_bot, created_at: Time.now - 5.hours)
          end

          before do
            chat_bot.update(reactivate_after: 12)
            customer.update(active_bot: true, chat_bot_option: chat_bot_option)
          end

          it 'continues the flow of the chat bot' do
            answer_message.message_payload = { 'type': 'text', 'text': 'quiero volver atras' }
            answer_message.save

            expect(customer.chat_bot_option_id).to eq(chat_bot_option_b.id)
          end
        end

        context 'when the message is received inside the reactivation time' do
          context 'when the text of the message matches the activation text of a bot' do
            let(:answer_message) { build(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer) }

            let!(:prev_message) do
              create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer, created_at:
                Time.now - 13.hours)
            end

            let!(:chat_bot_customer) do
              create(:chat_bot_customer, customer: customer, chat_bot: chat_bot, created_at: Time.now - 12.hours)
            end

            before do
              chat_bot.update(reactivate_after: 12)
              customer.update(active_bot: true, chat_bot_option: chat_bot_option_b)
            end

            it 'reactivates the chat bot from the beginning' do
              expect(customer.chat_bot_option_id).to eq(chat_bot_option_b.id)

              answer_message.message_payload = { 'type': 'text', 'text': 'hola test' }
              answer_message.save

              expect(customer.chat_bot_option_id).to eq(chat_bot_option.id)
            end
          end

          context 'when the text of the message does not match the activation text of any bot' do
            context 'when there is not bot activated with any interaction' do
              let(:answer_message) { build(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer) }

              let!(:prev_message) do
                create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer, created_at:
                  Time.now - 13.hours)
              end

              let!(:chat_bot_customer) do
                create(:chat_bot_customer, customer: customer, chat_bot: chat_bot, created_at: Time.now - 12.hours)
              end

              before do
                chat_bot.update(reactivate_after: 12)
                customer.update(active_bot: true, chat_bot_option: chat_bot_option_b)
              end

              it 'deactivates the bot to the customer' do
                expect(customer.chat_bot_option_id).to eq(chat_bot_option_b.id)

                answer_message.message_payload = { 'type': 'text', 'text': 'Probando' }
                answer_message.save

                expect(customer.active_bot).to be false
                expect(customer.chat_bot_option_id).to be_nil
              end
            end

            context 'when there is a bot activated with any interaction' do
              let(:answer_message) { build(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer) }

              let!(:chat_bot_option_d) do
                create(:chat_bot_option, chat_bot: chat_bot_any_interaction)
              end

              let(:chat_bot_any_interaction) do
                create(:chat_bot, :bot_enabled, :with_any_interaction, :for_whatsapp, retailer: retailer)
              end

              let!(:prev_message) do
                create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer, created_at:
                  Time.now - 13.hours)
              end

              let!(:chat_bot_customer) do
                create(:chat_bot_customer, customer: customer, chat_bot: chat_bot, created_at: Time.now - 12.hours)
              end

              before do
                chat_bot.update(reactivate_after: 12)
                customer.update(active_bot: true, chat_bot_option: chat_bot_option_b)
              end

              it 'deactivates the bot to the customer' do
                expect(customer.chat_bot_option_id).to eq(chat_bot_option_b.id)

                answer_message.message_payload = { 'type': 'text', 'text': 'Probando' }
                answer_message.save

                expect(customer.active_bot).to be true
                expect(customer.chat_bot_option_id).to eq(chat_bot_option_d.id)
              end
            end
          end
        end
      end
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
    let(:retailer) { create(:retailer, :gupshup_integrated, ws_balance: 10.0) }

    context 'when the message status is not error' do
      context 'when the message cost is not zero' do
        let(:message) { build(:gupshup_whatsapp_message, :outbound, :notification, retailer: retailer) }

        it 'assigns the customer conversation/notification cost to the message' do
          expect(message.cost).to be nil
          message.save
          expect(message.reload.cost).to eq(message.customer.ws_notification_cost)
          expect(retailer.reload.ws_balance).to eq(10.0 - message.cost)
        end
      end

      context 'when the message cost is zero' do
        let(:message) { build(:gupshup_whatsapp_message, :outbound, :conversation, retailer: retailer) }

        it 'does not change the message cost' do
          expect(message.cost).to be_nil
          message.save
          expect(message.reload.cost).to eq(0.0)
          expect(retailer.reload.ws_balance).to eq(10.0)
        end
      end
    end

    context 'when the message status is error' do
      context 'when the message cost is not zero' do
        let(:message) { create(:gupshup_whatsapp_message, :outbound, :notification, retailer: retailer) }

        it 'sets the message cost to zero' do
          expect(message.cost).to eq(message.customer.ws_notification_cost)
          expect(retailer.ws_balance).to eq(10.0 - message.customer.ws_notification_cost)
          message.update(status: 'error')
          expect(message.reload.cost).to eq(0.0)
          expect(retailer.reload.ws_balance).to eq(10.0)
        end
      end

      context 'when the message cost is zero' do
        let(:message) { create(:gupshup_whatsapp_message, :outbound, :conversation, retailer: retailer) }

        it 'does not change the message cost' do
          expect(message.cost).to eq(message.customer.ws_conversation_cost)
          expect(retailer.ws_balance).to eq(10.0 - message.customer.ws_conversation_cost)
          message.update(status: 'error')
          expect(message.reload.cost).to eq(0.0)
          expect(retailer.reload.ws_balance).to eq(10.0)
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

  describe '#retry_message' do
    let(:retailer) { create(:retailer, :gupshup_integrated) }
    let(:customer) { create(:customer, retailer: retailer, phone: '+5215599999999', country_id: 'MX') }
    let(:net_response) { Net::HTTPOK.new(1.0, '200', 'OK') }
    let(:customer_to_use) do
      create(:customer, retailer: retailer, phone: '+5215599999999', number_to_use: '+525599999999', country_id: 'MX')
    end

    let(:ok_body_response) do
      {
        'status': 'submitted',
        'messageId': 'c011a9c0-051d-4e01-a130-7b12903decb8'
      }.to_json
    end

    let(:error_response_1005) do
      {
        'app': 'MercatelyTest',
        'timestamp': 1617133991906,
        'version': 2,
        'type': 'message-event',
        'payload': {
          'id': 'e0058485-4fa3-415f-b299-d47274e2017f',
          'type': 'failed',
          'destination': '5215599999999',
          'payload': {
            'code': 1005,
            'reason': 'Message sending failed as user is inactive for session message and template did not match'
          }
        }
      }
    end

    let(:error_response_1002) do
      {
        'app': 'MercatelyTest',
        'timestamp': 1617133991906,
        'version': 2,
        'type': 'message-event',
        'payload': {
          'id': 'e0058485-4fa3-415f-b299-d47274e2017f',
          'type': 'failed',
          'destination': '5215599999999',
          'payload': {
            'code': 1002,
            'reason': 'Number Does Not Exists On WhatsApp'
          }
        }
      }
    end

    let(:text_payload) do
      {
        'isHSM': 'false',
        'type': 'text',
        'text': 'Test'
      }
    end

    let(:template_payload) do
      {
        'isHSM': 'true',
        'type': 'text',
        'text': 'Your OTP for 1 is 2. This is valid for 3.',
        'id': '997dd550-c8d8-4bf7-ad98-a5ac4844a1ed',
        'params': [
          '1',
          '2',
          '3'
        ]
      }
    end

    let(:document_payload) do
      {
        'type': 'file',
        'url': 'https://res.cloudinary.com/dhhrdm74a/raw/upload/v1617135241/' \
          'Informacio%CC%81n%20para%20el%20registro%20de%20la%20empresa%20%281%29.docx',
        'filename': 'informacion-para-el-registro-de-la-empresa-1'
      }
    end

    let(:document_template_payload) do
      {
        'isHSM': 'true',
        'type': 'file',
        'url': 'https://res.cloudinary.com/dhhrdm74a/raw/upload/v1606413278/nvpot3kncgybpncukoo0.pdf',
        'caption': 'Estimado Henry cómo estás? 🙋 Te saluda Elvis de AutoSeguro, gracias por utilizar nuestro ' \
          'servicio.\n\nNos habías solicitado una cotización para el Seguro de Tu Auto🚘 que incluye la cobertura ' \
          'de Amparo Patrimonial <U+200D>😮!\n\nEnviamos al correo registrado 📩. Si en el caso que no la pudiste ' \
          'mirar 👀, aquí te la hacemos llegar.\n\nAhora Si Tu Auto Va a Estar 100% PROTEGIDO..! 💯\n\nEs una muy ' \
          'buena oportunidad, si realmente quieres sentirte seguro.\n\nRecuerda que la puedes pagar hasta 12 meses ' \
          'SIN INTERESES.👌\n\nSi tienes alguna duda o pregunta escríbeme, estoy aquí para ayudarte.\n\nSaludos ' \
          'Cordiales. 🙂',
        'filename': 'notas-para-tareas-comunes.pdf'
      }
    end

    let(:image_payload) do
      {
        'type': 'image',
        'originalUrl': 'https://res.cloudinary.com/dhhrdm74a/image/upload/v1617135467/sr68x4ubgkhfdf1dwljj.png',
        'previewUrl': 'https://res.cloudinary.com/dhhrdm74a/image/upload/v1617135467/sr68x4ubgkhfdf1dwljj.png',
        'caption': ''
      }
    end

    let(:image_with_caption_payload) do
      {
        'type': 'image',
        'originalUrl': 'https://res.cloudinary.com/dhhrdm74a/image/upload/FeCgH7dy8Fe6nGWbWVsVuX3L',
        'previewUrl': 'https://res.cloudinary.com/dhhrdm74a/image/upload/FeCgH7dy8Fe6nGWbWVsVuX3L',
        'caption': 'Caption de ejemplo.\\n\\nCon saltos de linea para probar el pre-line nuevo de las divisiones.' \
          '\\n\\nBye!'
      }
    end

    let(:location_payload) do
      {
        'type': 'location',
        'longitude': -67.5894155,
        'latitude': 10.2546799
      }
    end

    let(:audio_payload) do
      {
        'type': 'audio',
        'url': 'https://res.cloudinary.com/dhhrdm74a/video/upload/v1617136125/cu12du9kppdapj1q0hyl.aac'
      }
    end

    context 'when the message status is not error' do
      let!(:gsm) do
        create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer,
          message_payload: text_payload)
      end

      it 'does not retry sending the message to the auxiliar number' do
        expect {
          gsm.send(:retry_message)
        }.to change(GupshupWhatsappMessage, :count).by(0)
      end
    end

    context 'when the message is not outbound' do
      let!(:gsm) do
        create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer,
          message_payload: text_payload, status: 'error')
      end

      it 'does not retry sending the message to the auxiliar number' do
        expect {
          gsm.send(:retry_message)
        }.to change(GupshupWhatsappMessage, :count).by(0)
      end
    end

    context 'when the customer is not from Mexico' do
      let(:ve_customer) { create(:customer, retailer: retailer, phone: '+584125558899', country_id: 'VE') }
      let!(:gsm) do
        create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: ve_customer,
          message_payload: text_payload, status: 'error')
      end

      it 'does not retry sending the message to the auxiliar number' do
        expect {
          gsm.send(:retry_message)
        }.to change(GupshupWhatsappMessage, :count).by(0)
      end
    end

    context 'when the message error_payload is blank' do
      let!(:gsm) do
        create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer,
          message_payload: text_payload, status: 'error')
      end

      it 'does not retry sending the message to the auxiliar number' do
        expect {
          gsm.send(:retry_message)
        }.to change(GupshupWhatsappMessage, :count).by(0)
      end
    end

    context 'when the message error_payload is present but is not the error code 1005' do
      let!(:gsm) do
        create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer,
          message_payload: text_payload, status: 'error', error_payload: error_response_1002)
      end

      it 'does not retry sending the message to the auxiliar number' do
        expect {
          gsm.send(:retry_message)
        }.to change(GupshupWhatsappMessage, :count).by(0)
      end
    end

    context 'when the customer does not have number to use' do
      let!(:gsm) do
        create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer,
          message_payload: text_payload, status: 'error', error_payload: error_response_1002)
      end

      it 'does not retry sending the message to the auxiliar number' do
        expect {
          gsm.send(:retry_message)
        }.to change(GupshupWhatsappMessage, :count).by(0)
      end
    end

    context 'when the customer has number to use but it is equal to the phone number' do
      let(:same_customer) do
        create(:customer, retailer: retailer, phone: '+5215599999999', number_to_use: '+5215599999999',
          country_id: 'MX')
      end

      let!(:gsm) do
        create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: same_customer,
          message_payload: text_payload, status: 'error', error_payload: error_response_1005)
      end

      it 'does not retry sending the message to the auxiliar number' do
        expect {
          gsm.send(:retry_message)
        }.to change(GupshupWhatsappMessage, :count).by(0)
      end
    end

    context 'when the message destination is equal to the number to use' do
      let(:same_customer) do
        create(:customer, retailer: retailer, phone: '+5215599999999', number_to_use: '+525599999999',
          country_id: 'MX')
      end

      let!(:gsm) do
        create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: same_customer,
          message_payload: text_payload, status: 'error', error_payload: error_response_1005)
      end

      it 'does not retry sending the message to the auxiliar number' do
        expect {
          gsm.send(:retry_message)
        }.to change(GupshupWhatsappMessage, :count).by(0)
      end
    end

    context 'when all the requirements are fullfiled' do
      before do
        allow_any_instance_of(Whatsapp::Gupshup::V1::Base).to receive(:post).and_return(net_response)
        allow_any_instance_of(Net::HTTPOK).to receive(:read_body).and_return(ok_body_response)
      end

      context 'when it is a text message' do
        let!(:gsm) do
          create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_to_use,
            message_payload: text_payload, status: 'error', error_payload: error_response_1005,
            destination: customer_to_use.phone_number(false))
        end

        it 'sends the message to the auxiliar number' do
          expect {
            gsm.send(:retry_message)
          }.to change(GupshupWhatsappMessage, :count).by(1)

          last_message = GupshupWhatsappMessage.last

          expect(gsm.message_payload).to eq(last_message.message_payload)
          expect(last_message.destination).to eq(customer_to_use.phone_number_to_use(false))
        end
      end

      context 'when it is a template message' do
        let!(:gsm) do
          create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_to_use,
            message_payload: template_payload, status: 'error', error_payload: error_response_1005,
            destination: customer_to_use.phone_number(false))
        end

        it 'sends the message to the auxiliar number' do
          expect {
            gsm.send(:retry_message)
          }.to change(GupshupWhatsappMessage, :count).by(1)

          last_message = GupshupWhatsappMessage.last

          expect(gsm.message_payload).to eq(last_message.message_payload)
          expect(last_message.destination).to eq(customer_to_use.phone_number_to_use(false))
        end
      end

      context 'when it is a document message' do
        let!(:gsm) do
          create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_to_use,
            message_payload: document_payload, status: 'error', error_payload: error_response_1005,
            destination: customer_to_use.phone_number(false))
        end

        it 'sends the message to the auxiliar number' do
          expect {
            gsm.send(:retry_message)
          }.to change(GupshupWhatsappMessage, :count).by(1)

          last_message = GupshupWhatsappMessage.last

          expect(gsm.message_payload).to eq(last_message.message_payload)
          expect(last_message.destination).to eq(customer_to_use.phone_number_to_use(false))
        end
      end

      context 'when it is a document message as template' do
        let!(:gsm) do
          create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_to_use,
            message_payload: document_template_payload, status: 'error', error_payload: error_response_1005,
            destination: customer_to_use.phone_number(false))
        end

        it 'sends the message to the auxiliar number' do
          expect {
            gsm.send(:retry_message)
          }.to change(GupshupWhatsappMessage, :count).by(1)

          last_message = GupshupWhatsappMessage.last

          expect(gsm.message_payload).to eq(last_message.message_payload)
          expect(last_message.destination).to eq(customer_to_use.phone_number_to_use(false))
        end
      end

      context 'when it is an image message' do
        let!(:gsm) do
          create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_to_use,
            message_payload: image_payload, status: 'error', error_payload: error_response_1005,
            destination: customer_to_use.phone_number(false))
        end

        it 'sends the message to the auxiliar number' do
          expect {
            gsm.send(:retry_message)
          }.to change(GupshupWhatsappMessage, :count).by(1)

          last_message = GupshupWhatsappMessage.last

          expect(gsm.message_payload).to eq(last_message.message_payload)
          expect(last_message.destination).to eq(customer_to_use.phone_number_to_use(false))
        end
      end

      context 'when it is an image message with caption' do
        let!(:gsm) do
          create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_to_use,
            message_payload: image_with_caption_payload, status: 'error', error_payload: error_response_1005,
            destination: customer_to_use.phone_number(false))
        end

        it 'sends the message to the auxiliar number' do
          expect {
            gsm.send(:retry_message)
          }.to change(GupshupWhatsappMessage, :count).by(1)

          last_message = GupshupWhatsappMessage.last

          expect(gsm.message_payload).to eq(last_message.message_payload)
          expect(last_message.destination).to eq(customer_to_use.phone_number_to_use(false))
        end
      end

      context 'when it is a location message' do
        let!(:gsm) do
          create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_to_use,
            message_payload: location_payload, status: 'error', error_payload: error_response_1005,
            destination: customer_to_use.phone_number(false))
        end

        it 'sends the message to the auxiliar number' do
          expect {
            gsm.send(:retry_message)
          }.to change(GupshupWhatsappMessage, :count).by(1)

          last_message = GupshupWhatsappMessage.last

          expect(gsm.message_payload).to eq(last_message.message_payload)
          expect(last_message.destination).to eq(customer_to_use.phone_number_to_use(false))
        end
      end

      context 'when it is an audio message' do
        let!(:gsm) do
          create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_to_use,
            message_payload: audio_payload, status: 'error', error_payload: error_response_1005,
            destination: customer_to_use.phone_number(false))
        end

        it 'sends the message to the auxiliar number' do
          expect {
            gsm.send(:retry_message)
          }.to change(GupshupWhatsappMessage, :count).by(1)

          last_message = GupshupWhatsappMessage.last

          expect(gsm.message_payload).to eq(last_message.message_payload)
          expect(last_message.destination).to eq(customer_to_use.phone_number_to_use(false))
        end
      end
    end
  end

  describe '#substract_from_balance' do
    context 'when the retailer has an unlimited account' do
      context 'when inbound messages' do
        let(:retailer) { create(:retailer, :gupshup_integrated, ws_balance: 5, unlimited_account: true) }
        let(:message) { create(:gupshup_whatsapp_message, :inbound, retailer: retailer) }

        it 'does not charge cost to balance' do
          expect(message.cost).to be_nil
          expect(retailer.reload.ws_balance).to eq(5.0)
        end
      end

      context 'when conversation messages' do
        let(:retailer) { create(:retailer, :gupshup_integrated, ws_balance: 5, unlimited_account: true) }
        let(:message) { create(:gupshup_whatsapp_message, :outbound, :conversation, retailer: retailer) }

        it 'does not charge cost to balance' do
          expect(message.cost).to be_nil
          expect(retailer.reload.ws_balance).to eq(5.0)
        end
      end
    end

    context 'when the retailer does not have an unlimited account' do
      context 'when inbound messages' do
        let(:retailer) { create(:retailer, :gupshup_integrated, ws_balance: 5) }
        let(:message) { create(:gupshup_whatsapp_message, :inbound, retailer: retailer) }

        it 'does not charge cost to balance' do
          expect(message.cost).to eq(0.0)
          expect(retailer.reload.ws_balance).to eq(5.0)
        end
      end

      context 'when conversation messages' do
        let(:retailer) { create(:retailer, :gupshup_integrated, ws_balance: 5) }
        let(:message) { create(:gupshup_whatsapp_message, :outbound, :conversation, retailer: retailer) }

        it 'does not charge cost to balance' do
          expect(message.cost).to eq(0.0)
          expect(retailer.reload.ws_balance).to eq(5.0)
        end
      end
    end

    context 'when the message is of notification type' do
      let(:retailer) { create(:retailer, :gupshup_integrated, ws_balance: 5, unlimited_account: true) }
      let(:customer) { create(:customer, retailer: retailer, ws_notification_cost: 0.0565) }

      context 'when the chat is open' do
        let!(:inbound_message) do
          create(:gupshup_whatsapp_message, :inbound, :conversation, retailer: retailer, customer: customer,
            created_at: Time.now - 10.hours)
        end

        let(:message) do
          create(:gupshup_whatsapp_message, :outbound, :notification, retailer: retailer, customer: customer,
            created_at: Time.now)
        end

        it 'does not charge cost to balance' do
          expect(message.cost).to eq(0.0)
          expect(retailer.reload.ws_balance).to eq(5.0)
        end
      end

      context 'when the chat is closed' do
        let!(:inbound_message) do
          create(:gupshup_whatsapp_message, :inbound, :conversation, retailer: retailer, customer: customer,
            created_at: Time.now - 30.hours)
        end

        let(:message) do
          create(:gupshup_whatsapp_message, :outbound, :notification, retailer: retailer, customer: customer,
            created_at: Time.now)
        end

        it 'charges cost to balance' do
          expect(message.cost).to eq(0.0565)
          expect(retailer.reload.ws_balance).to eq(4.9435)
        end
      end
    end
  end
end
