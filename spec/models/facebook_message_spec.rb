require 'rails_helper'

RSpec.describe FacebookMessage, type: :model do
  subject(:facebook_message) { create(:facebook_message, facebook_retailer: facebook_retailer) }

  let!(:retailer) { create(:retailer) }
  let!(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let!(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }

  describe 'associations' do
    it { is_expected.to belong_to(:facebook_retailer) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:retailer_user).required(false) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:mid).allow_blank }
  end

  describe '#sent_by_retailer?' do
    context 'when sender and facebook retailer are not the same' do
      it 'does not set to true the sent_by_retailer attribute' do
        expect(facebook_message.send(:sent_by_retailer?)).to be_nil
      end
    end

    context 'when sender and facebook retailer are the same' do
      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, sender_uid: facebook_retailer.uid)
      end

      it 'sets to true the sent_by_retailer attribute' do
        expect(facebook_msg_sent.send(:sent_by_retailer?)).to be true
      end
    end
  end

  describe '#send_facebook_message' do
    let(:set_facebook_messages_service) { instance_double(Facebook::Messages) }
    let(:facebook_msg_sent) do
      create(:facebook_message, facebook_retailer: facebook_retailer, sent_from_mercately: true, text: 'Testing')
    end

    let(:facebook_file_sent) do
      create(:facebook_message, facebook_retailer: facebook_retailer, sent_from_mercately: true, file_data:
        '/tmp/file.pdf')
    end

    let(:facebook_url_sent) do
      create(:facebook_message, facebook_retailer: facebook_retailer, sent_from_mercately: true, file_url:
        'https://www.images.com/image.jpg', file_type: 'image')
    end

    before do
      allow(set_facebook_messages_service).to receive(:send_message)
        .and_return(message_id: Faker::Internet.uuid)
      allow(set_facebook_messages_service).to receive(:send_attachment)
        .and_return(message_id: Faker::Internet.uuid)
      allow(Facebook::Messages).to receive(:new).with(facebook_retailer)
        .and_return(set_facebook_messages_service)
    end

    context 'when the message is sent from mercately' do
      context 'when the message is a text' do
        it 'calls the service to Facebok Message to send a text message' do
          expect(facebook_msg_sent.send(:send_facebook_message)).to be true
        end
      end

      context 'when the message contains an attachment' do
        it 'calls the service to Facebok Message to send an attachment message' do
          expect(facebook_file_sent.send(:send_facebook_message)).to be true
        end
      end

      context 'when the message contains an url' do
        it 'calls the service to Facebok Message to send an attachment message' do
          expect(facebook_url_sent.send(:send_facebook_message)).to be true
        end
      end
    end

    context 'when the message is not sent from mercately' do
      it 'does not call the Facebook Message service' do
        expect(facebook_message.send(:send_facebook_message)).to be_nil
      end
    end
  end

  describe '#send_welcome_message' do
    let(:set_facebook_messages_service) { instance_double(Facebook::Messages) }

    before do
      allow(set_facebook_messages_service).to receive(:send_message)
        .and_return('Sent')
      allow(Facebook::Messages).to receive(:new).with(facebook_retailer)
        .and_return(set_facebook_messages_service)
    end

    context 'when the retailer does not have an active welcome message configured' do
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_welcome_message)).to be nil
      end
    end

    context 'when the customer does not text for the first time' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :messenger, retailer: facebook_retailer.retailer) }
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let!(:first_facebook_message) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, text: 'Test')
      end

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_welcome_message)).to be nil
      end
    end

    context 'when the message is sent from the retailer' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :messenger, retailer: facebook_retailer.retailer) }
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          true, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_welcome_message)).to be nil
      end
    end

    context 'when all conditions are present' do
      let!(:automatic_answer) { create(:automatic_answer, :welcome, :messenger, retailer: facebook_retailer.retailer) }
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'sends the message' do
        expect { facebook_msg_sent.send(:send_welcome_message) }.to change(FacebookMessage, :count).by(2)
      end
    end
  end

  describe '#send_inactive_message' do
    let(:set_facebook_messages_service) { instance_double(Facebook::Messages) }

    before do
      allow(set_facebook_messages_service).to receive(:send_message)
        .and_return('Sent')
      allow(Facebook::Messages).to receive(:new).with(facebook_retailer)
        .and_return(set_facebook_messages_service)
    end

    context 'when the retailer does not have an inactive message configured' do
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let!(:first_facebook_message) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Test')
      end

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the customer does not have a prior message sent' do
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let!(:automatic_answer) do
        create(:automatic_answer, :inactive, :messenger, retailer: facebook_retailer.retailer)
      end

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the message is sent from the retailer' do
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let!(:automatic_answer) do
        create(:automatic_answer, :inactive, :messenger, retailer: facebook_retailer.retailer)
      end

      let!(:first_facebook_message) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Test')
      end

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          true, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_inactive_message)).to be nil
      end
    end

    context 'when the created time of the prior message is not passed yet' do
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let!(:automatic_answer) do
        create(:automatic_answer, :inactive, :messenger, retailer: facebook_retailer.retailer)
      end

      let!(:first_facebook_message) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Test', created_at: Time.now - 11.hours)
      end

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'returns nil' do
        expect(facebook_msg_sent.send(:send_inactive_message)).to be nil
      end
    end

    context 'when all conditions are present' do
      let(:customer) { create(:customer, retailer: facebook_retailer.retailer) }

      let!(:automatic_answer) do
        create(:automatic_answer, :inactive, :messenger, retailer: facebook_retailer.retailer)
      end

      let!(:first_facebook_message) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Test', created_at: Time.now - 13.hours)
      end

      let(:facebook_msg_sent) do
        create(:facebook_message, facebook_retailer: facebook_retailer, customer: customer, sent_by_retailer:
          false, text: 'Testing')
      end

      it 'sends the message' do
        expect { facebook_msg_sent.send(:send_inactive_message) }.to change(FacebookMessage, :count).by(3)
      end
    end
  end

  describe '#assign_agent' do
    context 'when the retailer has assignment teams permission' do
      let(:retailer) { create(:retailer, :with_team_assignment) }
      let(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }
      let(:another_retailer_user) { create(:retailer_user, retailer: retailer) }
      let(:customer) { create(:customer, retailer: retailer) }
      let(:customer2) { create(:customer, retailer: retailer) }

      let(:message) do
        create(:facebook_message, :inbound, customer: customer, facebook_retailer: facebook_retailer)
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
            create(
              :facebook_message,
              :outbound,
              customer: customer,
              facebook_retailer: facebook_retailer,
              retailer_user: retailer_user
            )
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
            create(
              :agent_team,
              :activated,
              team_assignment: default_team,
              retailer_user: retailer_user,
              max_assignments: 2,
              assigned_amount: 2
            )
          end

          let!(:agent_team2) do
            create(
              :agent_team,
              :activated,
              team_assignment: default_team,
              retailer_user: another_retailer_user,
              max_assignments: 4,
              assigned_amount: 4
            )
          end

          it 'does not assign an agent to the customer' do
            expect do
              create(:facebook_message, :inbound, customer: customer, facebook_retailer: facebook_retailer)
            end.to change(AgentCustomer, :count).by(0)
          end
        end

        context 'when there is at least one agent with free spots to assign' do
          let(:default_team) { create(:team_assignment, :assigned_default, retailer: retailer) }
          let!(:agent_team1) do
            create(
              :agent_team,
              :activated,
              team_assignment: default_team,
              retailer_user: retailer_user,
              max_assignments: 2,
              assigned_amount: 2
            )
          end

          let!(:agent_team2) do
            create(
              :agent_team,
              :activated,
              team_assignment: default_team,
              retailer_user: another_retailer_user,
              max_assignments: 4,
              assigned_amount: 3
            )
          end

          it 'assigns an agent to the customer' do
            expect do
              create(:facebook_message, :inbound, customer: customer, facebook_retailer: facebook_retailer)
            end.to change(AgentCustomer, :count).by(1)
          end
        end

        context 'when there is more than one agent with free spots to assign' do
          let(:default_team) { create(:team_assignment, :assigned_default, retailer: retailer) }
          let(:agent_team1) do
            create(
              :agent_team,
              :activated,
              team_assignment: default_team,
              retailer_user: retailer_user,
              max_assignments: 2,
              assigned_amount: 0
            )
          end

          let(:agent_team2) do
            create(
              :agent_team,
              :activated,
              team_assignment: default_team,
              retailer_user: another_retailer_user,
              max_assignments: 4,
              assigned_amount: 0
            )
          end

          it 'assigns the agent with less assignments to the customer and so on' do
            agent_team1
            agent_team2

            expect do
              create(:facebook_message, :inbound, customer: customer, facebook_retailer: facebook_retailer)
            end.to change(AgentCustomer, :count).by(1)

            last = AgentCustomer.last
            expect(agent_team1.retailer_user_id).to eq(last.retailer_user_id)
            expect(last.team_assignment_id).to eq(default_team.id)
            expect(agent_team1.reload.assigned_amount).to eq(1)

            expect do
              create(:facebook_message, :inbound, customer: customer2, facebook_retailer: facebook_retailer)
            end.to change(AgentCustomer, :count).by(1)

            last = AgentCustomer.last
            expect(agent_team2.retailer_user_id).to eq(last.retailer_user_id)
            expect(last.team_assignment_id).to eq(default_team.id)
            expect(agent_team2.reload.assigned_amount).to eq(1)
          end
        end
      end

      context 'when the message is outbound' do
        let!(:inbound_message) do
          create(:facebook_message, :inbound, customer: customer, facebook_retailer: facebook_retailer)
        end

        let(:outbound_message) do
          create(
            :facebook_message,
            :outbound,
            customer: customer,
            facebook_retailer: facebook_retailer,
            retailer_user: retailer_user
          )
        end

        context 'when the message does not come from an agent' do
          let(:not_from_agent) do
            create(:facebook_message, :outbound, customer: customer, facebook_retailer: facebook_retailer)
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
            create(
              :agent_team,
              :activated,
              team_assignment: default_team,
              retailer_user: retailer_user,
              max_assignments: 2,
              assigned_amount: 0
            )
          end

          let!(:agent_customer) do
            create(:agent_customer, customer: customer, retailer_user: retailer_user, team_assignment: default_team)
          end

          let!(:other_outbound) do
            create(
              :facebook_message,
              :outbound,
              customer: customer,
              facebook_retailer: facebook_retailer,
              retailer_user: retailer_user
            )
          end

          it 'returns nil' do
            expect(outbound_message.send(:assign_agent)).to be_nil
          end
        end

        context 'when the message is the first one sent to the customer' do
          let(:default_team) { create(:team_assignment, :assigned_default, retailer: retailer) }
          let!(:agent_team) do
            create(
              :agent_team,
              :activated,
              team_assignment: default_team,
              retailer_user: retailer_user,
              max_assignments: 2,
              assigned_amount: 1
            )
          end

          let!(:agent_customer) do
            create(:agent_customer, customer: customer, retailer_user: retailer_user, team_assignment: default_team)
          end

          it 'decreases by one the assigned amount of the agent team' do
            expect(agent_team.assigned_amount).to eq(1)

            create(
              :facebook_message,
              :outbound,
              customer: customer,
              facebook_retailer: facebook_retailer,
              retailer_user: retailer_user
            )

            expect(agent_team.reload.assigned_amount).to eq(0)
          end
        end
      end
    end

    context 'when the retailer does not have assignment teams permission' do
      let(:retailer) { create(:retailer) }
      let(:message) { create(:facebook_message, facebook_retailer: facebook_retailer) }

      it 'returns nil' do
        expect(message.send(:assign_agent)).to be_nil
      end
    end

    context 'when a chat is answered' do
      let(:customer) { create(:customer, retailer: retailer) }

      context 'when the message is not sent from an agent' do
        let(:outbound_message) do
          create(:facebook_message, :outbound, customer: customer, facebook_retailer: facebook_retailer)
        end

        it 'does not assign the customer to anyone' do
          outbound_message
          expect(customer.agent).to be_nil
        end
      end

      context 'when the message is sent from an agent' do
        let(:outbound_message) do
          create(
            :facebook_message,
            :outbound,
            customer: customer,
            facebook_retailer: facebook_retailer,
            retailer_user: retailer_user
          )
        end

        context 'when the customer does not have an agent yet' do
          it 'assigns the customer to the agent' do
            outbound_message
            expect(customer.agent).to eq(retailer_user)
          end
        end

        context 'when the customer already has an agent' do
          let(:retailer_user2) { create(:retailer_user, retailer: retailer) }
          let!(:agent_customer) { create(:agent_customer, customer: customer, retailer_user: retailer_user2) }

          it 'does not assign the customer to the agent' do
            outbound_message
            expect(customer.agent).to eq(retailer_user2)
          end
        end
      end
    end
  end
end
