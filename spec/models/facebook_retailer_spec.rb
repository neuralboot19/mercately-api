require 'rails_helper'

RSpec.describe FacebookRetailer, type: :model do
  let(:retailer) { create(:retailer) }

  describe '#add_sales_channel' do
    context 'when a facebook retailer is created' do
      it 'creates a messenger sales channel' do
        expect(retailer.sales_channels.size).to eq(0)

        FacebookRetailer.create(retailer: retailer)

        retailer.reload
        expect(retailer.sales_channels.size).to eq(1)
        expect(retailer.sales_channels.first.channel_type).to eq('messenger')
      end
    end
  end

  describe '#facebook_unread_messages' do
    let(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }
    let(:customer) { create(:customer, retailer: retailer) }
    let(:admin) { create(:retailer_user, :admin, retailer: retailer) }
    let(:supervisor) { create(:retailer_user, :supervisor, retailer: retailer) }
    let(:agent_all) { create(:retailer_user, :agent, retailer: retailer, only_assigned: false) }
    let(:agent_only_assigned) { create(:retailer_user, :agent, retailer: retailer, only_assigned: true) }

    let(:customer_admin) { create(:customer, retailer: retailer) }
    let!(:agent_customer_admin) { create(:agent_customer, customer: customer_admin, retailer_user: admin) }
    let(:customer_supervisor) { create(:customer, retailer: retailer) }
    let!(:agent_customer_supervisor) do
      create(:agent_customer, customer: customer_supervisor, retailer_user: supervisor)
    end

    let(:customer_agent_all) { create(:customer, retailer: retailer) }
    let!(:agent_customer_agent_all) { create(:agent_customer, customer: customer_agent_all, retailer_user: agent_all) }
    let(:customer_only_assigned) { create(:customer, retailer: retailer) }
    let!(:agent_customer_only_assigned) do
      create(:agent_customer, customer: customer_only_assigned, retailer_user: agent_only_assigned)
    end

    let!(:messages_admin) do
      create_list(:facebook_message, 2, :inbound, facebook_retailer: facebook_retailer, customer: customer_admin)
    end

    let!(:messages_supervisor) do
      create_list(:facebook_message, 4, :inbound, facebook_retailer: facebook_retailer, customer: customer_supervisor)
    end

    let!(:messages_agent_all) do
      create_list(:facebook_message, 3, :inbound, facebook_retailer: facebook_retailer, customer: customer_agent_all)
    end

    let!(:message_agent_only_assigned) do
      create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer_only_assigned)
    end

    let!(:messages_not_assigned) do
      create_list(:facebook_message, 3, :inbound, facebook_retailer: facebook_retailer, customer: customer)
    end

    # context 'when the retailer user is an admin' do
    #   it 'counts all the unread messages' do
    #     expect(facebook_retailer.facebook_unread_messages(admin).size).to eq(13)
    #   end
    # end

    # context 'when the retailer user is a supervisor' do
    #   it 'counts all the unread messages' do
    #     expect(facebook_retailer.facebook_unread_messages(supervisor).size).to eq(13)
    #   end
    # end

    # context 'when the retailer user is an agent that can see only assigned chats' do
    #   it 'counts the unread messages that only belong to that agent' do
    #     expect(facebook_retailer.facebook_unread_messages(agent_only_assigned).size).to eq(1)
    #   end
    # end

    # context 'when the retailer user is an agent that can see assigned and not assigned chats' do
    #   it 'counts the unread messages that belong to that agent and not assigned ones' do
    #     expect(facebook_retailer.facebook_unread_messages(agent_all).size).to eq(6)
    #   end
    # end
  end
end
