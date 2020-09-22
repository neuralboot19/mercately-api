require 'rails_helper'

RSpec.describe KarixWhatsappMessage, type: :model do
  let(:karix_response) do
    {
      'meta': {
        'request_uuid': '01678427-c79f-48f7-bf03-b04659611c2e',
        'available_credits': '1.51226',
        'credits_charged': '0.004'
      },
      'objects':
      [
        {
          'account_uid': '3a9f05a1-4e59-4504-9ca9-be9ec1934f2b',
          'channel': 'whatsapp',
          'channel_details': {
            'whatsapp': {
              'platform_fee': '0.004',
              'type': 'conversation',
              'whatsapp_fee': '0'
            }
          },
          'content': {
            'text': 'New Whatsapp message'
          },
          'content_type': 'text',
          'country': 'EC',
          'created_time': '2020-03-18T15:01:14.624018Z',
          'delivered_time': nil,
          'destination': '+593998999999',
          'direction': 'outbound',
          'error': nil,
          'redact': false,
          'refund': nil,
          'sent_time': nil,
          'source': '+13253077759',
          'status': 'queued',
          'total_cost': '0.004',
          'uid': '87f3c742-95e3-4bb3-a671-cce2705e1a21',
          'updated_time': nil
        }
      ]
    }.with_indifferent_access
  end

  before do
    allow_any_instance_of(Exponent::Push::Client).to receive(:send_messages).and_return(true)
  end

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:retailer_user).required(false) }
  end

  describe '#substract_from_balance' do
    let!(:retailer) { create(:retailer) }
    let!(:retailer_user) { create(:retailer_user, retailer: retailer) }

    let!(:customer1) { create(:customer, retailer: retailer) }
    let!(:customer2) { create(:customer, retailer: retailer) }

    it 'will not substract the retailer\'s ws_conversation_cost from the retailer balance if status is failed' do
      former_retailer_balance = retailer.ws_balance
      create(:karix_whatsapp_message, retailer: retailer, customer: customer1, message_type: 'conversation',
        status: 'failed')

      expect(retailer.reload.ws_balance).to eq(former_retailer_balance)
    end

    it 'will substract the retailer\'s ws_conversation_cost from the retailer balance if message_type is \'conversation\'' do
      former_retailer_balance = retailer.ws_balance
      create(:karix_whatsapp_message, retailer: retailer, customer: customer1, message_type: 'conversation')

      expect(retailer.reload.ws_balance).to eq(former_retailer_balance - retailer.ws_conversation_cost)
    end

    it 'will substract the retailer\'s ws_notification_cost from the retailer balance if message_type is \'notification\'' do
      former_retailer_balance = retailer.ws_balance

      create(:karix_whatsapp_message, retailer: retailer, customer: customer1, message_type: 'notification')
      expect(retailer.reload.ws_balance).to eq(former_retailer_balance - retailer.ws_notification_cost)
    end

    it 'expect not to set ws_next_notification_balance if ws_balance is > 1.5' do
      expect {
        create(:karix_whatsapp_message, retailer: retailer, customer: customer1)
      }.to_not change { retailer.ws_next_notification_balance }
    end

    it 'expect not to send a running out balance notification email if ws_balance is > 1.5' do
      expect {
        create(:karix_whatsapp_message, retailer: retailer, customer: customer1)
      }.to_not change { ActionMailer::Base.deliveries.size }
    end

    context 'if ws_balance <= to the current ws_next_notification_balance and it is > 0' do
      it 'will set ws_next_notification_balance down in -0.5 and send a running out balance notification email' do
        retailer.update_attributes(ws_balance: 1.4)

        expect {
          create(:karix_whatsapp_message, retailer: retailer, customer: customer1)
        }.to change { retailer.ws_next_notification_balance }.by(-0.5).and change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end

    context 'when the retailer has an unlimited account' do
      let(:retailer) { create(:retailer, unlimited_account: true) }

      context 'when it is a conversation message' do
        it 'does not subtract the balance' do
          expect {
            create(:karix_whatsapp_message, retailer: retailer, customer: customer1, message_type: 'conversation')
          }.to_not change { retailer.ws_balance }
        end
      end

      context 'when it is a notification message' do
        it 'subtracts the balance' do
          former_retailer_balance = retailer.ws_balance

          create(:karix_whatsapp_message, retailer: retailer, customer: customer1)
          expect(retailer.ws_balance).to eq(former_retailer_balance - retailer.ws_notification_cost)
        end
      end

      context 'when it is an inbound message' do
        it 'does not subtract the balance' do
          expect {
            create(:karix_whatsapp_message, retailer: retailer, customer: customer1, direction: 'inbound')
          }.to_not change { retailer.ws_balance }
        end
      end
    end
  end

  describe '#send_welcome_message' do
    let(:set_karix_messages_service) { Whatsapp::Karix::Messages.new }

    before do
      allow(set_karix_messages_service).to receive(:send_message)
        .and_return(karix_response)
      allow(Whatsapp::Karix::Messages).to receive(:new)
        .and_return(set_karix_messages_service)
    end

    context 'when the retailer does not have an active welcome message configured' do
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_welcome_message)).to be nil
      end
    end

    context 'when the customer does not text for the first time' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_welcome_message)).to be nil
      end
    end

    context 'when the message is not inbound' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:karix_whatsapp_message, :outbound, customer: customer, retailer: retailer)
      end

      it 'returns nil' do
        expect(message.send(:send_welcome_message)).to be nil
      end
    end

    context 'when all conditions are present' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer, retailer: customer.retailer)
      end

      it 'sends the message' do
        expect { message.send(:send_welcome_message) }.to change(KarixWhatsappMessage, :count).by(2)
        expect(KarixWhatsappMessage.last.content_text).to eq(karix_response['objects'][0]['content']['text'])
      end
    end
  end

  describe '#send_inactive_message' do
    let(:set_karix_messages_service) { Whatsapp::Karix::Messages.new }

    before do
      allow(set_karix_messages_service).to receive(:send_message)
        .and_return(karix_response)
      allow(Whatsapp::Karix::Messages).to receive(:new)
        .and_return(set_karix_messages_service)
    end

    context 'when the retailer does not have an inactive message configured' do
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the customer does not have a prior message sent' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the message is not inbound' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:karix_whatsapp_message, :inbound, customer: customer, retailer: retailer)
      end

      let(:message) do
        create(:karix_whatsapp_message, :outbound, customer: customer, retailer: retailer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the created time of the prior message is not passed yet' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:karix_whatsapp_message, :inbound, customer: customer, created_at:
          Time.now - 11.hours)
      end

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer)
      end

      it 'returns nil' do
        expect(message.send(:send_inactive_message)).to be nil
      end
    end

    context 'when all conditions are present' do
      let!(:automatic_answer) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:customer) { create(:customer, retailer: retailer) }

      let!(:first_message) do
        create(:karix_whatsapp_message, :inbound, retailer: retailer, customer: customer, created_at:
          Time.now - 13.hours)
      end

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer, retailer: customer.retailer)
      end

      it 'sends the message' do
        expect { message.send(:send_inactive_message) }.to change(KarixWhatsappMessage, :count).by(2)
        expect(KarixWhatsappMessage.last.content_text).to eq(karix_response['objects'][0]['content']['text'])
      end
    end
  end

  describe '#apply_cost' do
    let(:retailer) { create(:retailer, :karix_integrated) }

    context 'when the message status is failed' do
      let(:message) { build(:karix_whatsapp_message, retailer: retailer, status: 'failed') }

      it 'sets the message cost to zero' do
        expect(message.cost).to be nil
        message.save
        expect(message.reload.cost).to eq(0)
      end
    end

    context 'when the message status is not failed' do
      let(:message) { build(:karix_whatsapp_message, retailer: retailer, status: 'queued') }

      it 'assigns the retailer conversation/notification cost to the message' do
        expect(message.cost).to be nil
        message.save
        expect(message.reload.cost).to eq(retailer.send("ws_#{message.message_type}_cost"))
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
        create(:karix_whatsapp_message, :inbound, customer: customer)
      }.to have_enqueued_job(Retailers::MobilePushNotificationJob)
    end
  end

  describe '#assign_agent' do
    context 'when the retailer has assignment teams permission' do
      let(:retailer) { create(:retailer, :karix_integrated, :with_team_assignment) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }
      let(:another_retailer_user) { create(:retailer_user, retailer: retailer) }
      let(:customer) { create(:customer, retailer: retailer) }
      let(:customer2) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:karix_whatsapp_message, :inbound, customer: customer, retailer: retailer)
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
            create(:karix_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
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
              create(:karix_whatsapp_message, :inbound, customer: customer, retailer: retailer)
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
              create(:karix_whatsapp_message, :inbound, customer: customer, retailer: retailer)
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
              create(:karix_whatsapp_message, :inbound, customer: customer, retailer: retailer)
            }.to change(AgentCustomer, :count).by(1)

            last = AgentCustomer.last
            expect(agent_team1.retailer_user_id).to eq(last.retailer_user_id)
            expect(last.team_assignment_id).to eq(default_team.id)
            expect(agent_team1.reload.assigned_amount).to eq(1)

            expect {
              create(:karix_whatsapp_message, :inbound, customer: customer2, retailer: retailer)
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
          create(:karix_whatsapp_message, :inbound, customer: customer, retailer: retailer)
        end

        let(:outbound_message) do
          create(:karix_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
            retailer_user)
        end

        context 'when the message does not come from an agent' do
          let(:not_from_agent) do
            create(:karix_whatsapp_message, :outbound, customer: customer, retailer: retailer)
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
            create(:karix_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
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

            create(:karix_whatsapp_message, :outbound, customer: customer, retailer: retailer, retailer_user:
              retailer_user)

            expect(agent_team.reload.assigned_amount).to eq(0)
          end
        end
      end
    end

    context 'when the retailer does not have assignment teams permission' do
      let(:retailer) { create(:retailer, :karix_integrated) }
      let(:message) { create(:karix_whatsapp_message, retailer: retailer) }

      it 'returns nil' do
        expect(message.send(:assign_agent)).to be_nil
      end
    end
  end

  describe 'chat bots execution' do
    let(:set_karix_messages_service) { Whatsapp::Karix::Messages.new }

    before do
      allow(set_karix_messages_service).to receive(:send_message).and_return(karix_response)
      allow(Whatsapp::Karix::Messages).to receive(:new).and_return(set_karix_messages_service)
    end

    context 'chat bot options with media' do
      let(:root_option) { create(:chat_bot_option, text: 'Root node') }
      let(:chat_bot_option_image) {create(:chat_bot_option,  :with_image_file, parent: root_option, position: 1, text: '1 Image')}
      let(:chat_bot_option_pdf) {create(:chat_bot_option, :with_pdf_file, parent: root_option, position: 2, text: '2 PDF')}
      let(:chat_bot) { create(:chat_bot, :bot_enabled, :with_accented_trigger, chat_bot_options: [root_option, chat_bot_option_image, chat_bot_option_pdf], trigger: 'Estoy interesado en Mercately' ) }
      let(:retailer) { create(:retailer, :karix_integrated, :with_chat_bots, chat_bots: [chat_bot]) }
      let(:customer) { create(:customer, :able_to_start_bots, retailer: retailer) }
      let(:message) do
        build(:karix_whatsapp_message, :inbound, customer: customer, retailer: retailer, content_type: 'text',
          content_text: 'Estoy interesado en Mercately')
      end

      let(:answer_message) do
        build(:karix_whatsapp_message, :inbound, customer: customer, retailer: retailer, content_type: 'text')
      end

      it 'selects a chat bot option with image' do
        message.save!
        answer_message.content_text = '1'
        answer_message.save!
        expect(customer.chat_bot_option_id).to eq(chat_bot_option_image.id)
      end

      it 'selects a chat bot option with pdf' do
        message.save!
        answer_message.content_text = '2'
        answer_message.save!
        expect(customer.chat_bot_option_id).to eq(chat_bot_option_pdf.id)
      end
    end
  end
end
