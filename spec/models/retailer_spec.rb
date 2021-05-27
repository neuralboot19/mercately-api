require 'rails_helper'
require 'bcrypt'

RSpec.describe Retailer, type: :model do
  subject(:retailer) { build(:retailer) }

  describe 'enums' do
    it { is_expected.to define_enum_for(:id_type).with_values(%i[cedula pasaporte ruc rut otro]) }
  end

  describe 'associations' do
    it { is_expected.to have_one(:meli_retailer) }
    it { is_expected.to have_one(:retailer_user) }
    it { is_expected.to have_one(:facebook_catalog) }

    it { is_expected.to have_many(:products) }
    it { is_expected.to have_many(:customers) }
    it { is_expected.to have_many(:retailer_users) }
    it { is_expected.to have_many(:templates) }
    it { is_expected.to have_many(:automatic_answers) }
    it { is_expected.to have_many(:payment_methods) }
    it { is_expected.to have_many(:tags).dependent(:destroy) }
    it { is_expected.to have_many(:sales_channels).dependent(:destroy) }
    it { is_expected.to have_many(:paymentez_transactions) }
    it { is_expected.to have_many(:paymentez_credit_cards).dependent(:destroy) }
    it { is_expected.to have_many(:team_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:chat_bot_customers).through(:customers) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  it 'after save a name generates a slug' do
    expect(retailer.slug).to be_nil
    retailer.save
    expect(retailer.slug).not_to be_nil
  end

  it 'sets default ws_conversation_cost int_charges allow_voice_notes when created' do
    retailer = Retailer.create(name: 'Retailer Name')

    expect(retailer.ws_conversation_cost).to eq(0.0)
    expect(retailer.int_charges).to eq(true)
    expect(retailer.allow_voice_notes).to eq(true)
  end

  context 'when there are retailers with the same name' do
    let(:retailer_2) { create(:retailer, name: retailer.name) }

    it 'generates a slug with the retailer id' do
      retailer.save
      expect(retailer_2.slug).not_to eq retailer.slug
      expect(retailer_2.slug).to eq "#{retailer_2.name}-#{retailer_2.id}".parameterize
    end
  end

  # TODO: move method to MeliRetailer
  describe '#update_meli_access_token' do
    subject(:retailer) { create(:retailer) }

    let!(:meli_retailer) { create(:meli_retailer, retailer: retailer) }
    let!(:access_token) { meli_retailer.access_token }

    context 'when meli_retailer.meli_token_updated_at is more than current hour - 4' do
      it 'does not update the access_token' do
        retailer.update_meli_access_token
        expect(meli_retailer.access_token).to eq access_token
      end
    end

    context 'when meli_retailer.meli_token_updated_at is minor than current hour - 4' do
      let(:ml_auth) { instance_double(MercadoLibre::Auth) }

      before do
        allow(ml_auth).to receive(:refresh_access_token)
          .and_return(meli_retailer.update(access_token: Faker::Blockchain::Bitcoin.address))
        allow(MercadoLibre::Auth).to receive(:new).with(retailer)
          .and_return(ml_auth)
      end

      it 'updates the access_token' do
        meli_retailer.update meli_token_updated_at: Time.now - 6.hours
        retailer.update_meli_access_token
        expect(meli_retailer.access_token).not_to eq access_token
      end
    end
  end

  describe '#unread_messages' do
    let(:customer) { create(:customer, retailer: retailer) }
    let(:order) { create(:order, customer: customer) }
    let!(:unread_messages) { create_list(:message, 5, order: order, customer: customer) }
    let!(:readed_messages) { create_list(:message, 3, :readed, order: order, customer: customer) }

    it 'returns only the unreaded messages' do
      expect(retailer.unread_messages.count).to eq 5
    end
  end

  describe '#unread_questions' do
    let(:product) { create(:product, retailer: retailer) }
    let(:customer) { create(:customer, retailer: retailer) }
    let!(:unread_questions) { create_list(:question, 5, product: product, customer: customer) }
    let!(:readed_questions) { create_list(:question, 3, :readed, product: product, customer: customer) }

    it 'returns only the unreaded questions' do
      expect(retailer.unread_questions.count).to eq 5
    end
  end

  describe '#incomplete_meli_profile?' do
    context 'when id_number, address, city or state are filled' do
      it 'returns false' do
        expect(retailer.incomplete_meli_profile?).to be false
      end
    end

    context 'when any of id_number, address, city or state is empty' do
      it 'returns true' do
        retailer.id_number = nil
        expect(retailer.incomplete_meli_profile?).to be true
      end
    end
  end

  describe '#generate_api_key' do
    it 'returns unique api_key string of 32 chars and stores the encripted api_key to the db' do
      api_key = retailer.generate_api_key
      expect(api_key.size).to be 32
      expect(Retailer.where.not(encrypted_api_key: nil).count).to be 1
    end
  end

  describe '#to_param' do
    it 'returns the retailer slug' do
      retailer.save
      expect(retailer.to_param).to eq(retailer.slug)
    end
  end

  describe '#karix_unread_whatsapp_messages' do
    subject(:retailer) { create(:retailer) }

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
      create_list(:karix_whatsapp_message, 2, :inbound, retailer: retailer, customer: customer_admin, status:
        'delivered')
    end

    let!(:messages_supervisor) do
      create_list(:karix_whatsapp_message, 4, :inbound, retailer: retailer, customer: customer_supervisor, status:
        'delivered')
    end

    let!(:messages_agent_all) do
      create_list(:karix_whatsapp_message, 3, :inbound, retailer: retailer, customer: customer_agent_all, status:
        'delivered')
    end

    let!(:message_agent_only_assigned) do
      create(:karix_whatsapp_message, :inbound, retailer: retailer, customer: customer_only_assigned, status:
        'delivered')
    end

    let!(:messages_not_assigned) do
      create_list(:karix_whatsapp_message, 3, :inbound, retailer: retailer, customer: customer, status:
        'delivered')
    end

    before do
      allow_any_instance_of(Exponent::Push::Client).to receive(:send_messages).and_return(true)
    end

    context 'when the retailer user is an admin' do
      it 'counts all the unread messages' do
        expect(retailer.karix_unread_whatsapp_messages(admin).size).to eq(13)
      end
    end

    context 'when the retailer user is a supervisor' do
      it 'counts all the unread messages' do
        expect(retailer.karix_unread_whatsapp_messages(supervisor).size).to eq(13)
      end
    end

    context 'when the retailer user is an agent that can see only assigned chats' do
      it 'counts the unread messages that only belong to that agent' do
        expect(retailer.karix_unread_whatsapp_messages(agent_only_assigned).size).to eq(1)
      end
    end

    context 'when the retailer user is an agent that can see assigned and not assigned chats' do
      it 'counts the unread messages that belong to that agent and not assigned ones' do
        expect(retailer.karix_unread_whatsapp_messages(agent_all).size).to eq(6)
      end
    end
  end

  describe '#gupshup_unread_whatsapp_messages' do
    subject(:retailer) { create(:retailer) }

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
      create_list(:gupshup_whatsapp_message, 2, :inbound, retailer: retailer, customer: customer_admin, status: 4)
    end

    let!(:messages_supervisor) do
      create_list(:gupshup_whatsapp_message, 4, :inbound, retailer: retailer, customer: customer_supervisor, status: 4)
    end

    let!(:messages_agent_all) do
      create_list(:gupshup_whatsapp_message, 3, :inbound, retailer: retailer, customer: customer_agent_all, status: 4)
    end

    let!(:message_agent_only_assigned) do
      create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer_only_assigned, status: 4)
    end

    let!(:messages_not_assigned) do
      create_list(:gupshup_whatsapp_message, 3, :inbound, retailer: retailer, customer: customer, status: 4)
    end

    before do
      allow_any_instance_of(Exponent::Push::Client).to receive(:send_messages).and_return(true)
    end

    context 'when the retailer user is an admin' do
      it 'counts all the unread messages' do
        expect(retailer.gupshup_unread_whatsapp_messages(admin).size).to eq(13)
      end
    end

    context 'when the retailer user is a supervisor' do
      it 'counts all the unread messages' do
        expect(retailer.gupshup_unread_whatsapp_messages(supervisor).size).to eq(13)
      end
    end

    context 'when the retailer user is an agent that can see only assigned chats' do
      it 'counts the unread messages that only belong to that agent' do
        expect(retailer.gupshup_unread_whatsapp_messages(agent_only_assigned).size).to eq(1)
      end
    end

    context 'when the retailer user is an agent that can see assigned and not assigned chats' do
      it 'counts the unread messages that belong to that agent and not assigned ones' do
        expect(retailer.gupshup_unread_whatsapp_messages(agent_all).size).to eq(6)
      end
    end
  end

  describe '#team_agents' do
    subject(:retailer) { create(:retailer) }

    let!(:retailer_user_admin) do
      create(:retailer_user, :with_retailer, :admin, retailer: retailer, invitation_token: nil)
    end

    let!(:retailer_user_agent) do
      create(:retailer_user, :with_retailer, :agent, retailer: retailer, invitation_accepted_at:
        Date.today, invitation_token: nil)
    end

    let!(:retailer_user_supervisor) do
      create(:retailer_user, :with_retailer, :supervisor, retailer: retailer, invitation_accepted_at:
        Date.today, invitation_token: nil)
    end

    let!(:retailer_user_agent_two) do
      create(:retailer_user, :with_retailer, :agent, retailer: retailer, invitation_accepted_at:
        Date.today, removed_from_team: true, invitation_token: nil)
    end

    let!(:retailer_user_admin_two) do
      create(:retailer_user, :with_retailer, :admin, retailer: retailer, invitation_token: 'test-token')
    end

    let!(:retailer_user_supervisor_two) do
      create(:retailer_user, :with_retailer, :supervisor, retailer: retailer, invitation_token: 'test-token1')
    end

    it 'returns the active retailer users belonging to the retailer' do
      expect(retailer.team_agents.count).to eq(3)
    end
  end

  describe '#admins' do
    subject(:retailer) { create(:retailer) }

    let!(:retailer_user_admin1) { create(:retailer_user, :with_retailer, :admin, retailer: retailer) }
    let!(:retailer_user_admin2) { create(:retailer_user, :with_retailer, :admin, retailer: retailer) }

    it 'returns all admins for the retailer' do
      expect(retailer.admins.order(id: :desc).to_a).to eq(RetailerUser.where(retailer_admin: true).order(id: :desc).to_a)
    end
  end

  describe '#positive_balance?' do
    subject(:retailer) { create(:retailer, :gupshup_integrated) }

    context 'when customer chat is open' do
      let(:customer) { create(:customer, retailer: retailer, ws_notification_cost: '0.05') }
      let!(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer,
          created_at: Time.now - 10.hours)
      end

      it 'returns true if balance is minor than notification cost' do
        retailer.ws_balance = 0.01
        retailer.save
        expect(retailer.positive_balance?(customer)).to eq(true)
      end

      it 'returns true if balance is greater than notification cost' do
        retailer.ws_balance = 1.0
        retailer.save
        expect(retailer.positive_balance?(customer)).to eq(true)
      end
    end

    context 'when customer chat is closed' do
      let(:customer) { create(:customer, retailer: retailer, ws_notification_cost: '0.05') }
      let!(:message) do
        create(:gupshup_whatsapp_message, :inbound, customer: customer, retailer: retailer,
          created_at: Time.now - 30.hours)
      end

      it 'returns false if balance is minor than notification cost' do
        retailer.ws_balance = 0.01
        retailer.save
        expect(retailer.positive_balance?(customer)).to eq(false)
      end

      it 'returns true if balance is greater than notification cost' do
        retailer.ws_balance = 1.0
        retailer.save
        expect(retailer.positive_balance?(customer)).to eq(true)
      end
    end
  end

  describe '#whatsapp_welcome_message' do
    subject(:retailer) { create(:retailer) }

    context 'when the retailer has a whatsapp active welcome message configured' do
      let!(:welcome_message) { create(:automatic_answer, :welcome, :whatsapp, retailer: retailer) }

      it 'returns it' do
        expect(retailer.whatsapp_welcome_message).to be_an_instance_of(AutomaticAnswer)
      end
    end

    context 'when the retailer does not have a whatsapp active welcome message configured' do
      it 'returns nil' do
        expect(retailer.whatsapp_welcome_message).to be nil
      end
    end
  end

  describe '#whatsapp_inactive_message' do
    subject(:retailer) { create(:retailer) }

    context 'when the retailer has a whatsapp inactive message configured' do
      let!(:inactive_message) { create(:automatic_answer, :inactive, :whatsapp, retailer: retailer) }

      it 'returns it' do
        expect(retailer.whatsapp_inactive_message).to be_an_instance_of(AutomaticAnswer)
      end
    end

    context 'when the retailer does not have a whatsapp inactive message configured' do
      it 'returns nil' do
        expect(retailer.whatsapp_inactive_message).to be nil
      end
    end
  end

  describe '#messenger_welcome_message' do
    subject(:retailer) { create(:retailer) }

    context 'when the retailer has a messenger active welcome message configured' do
      let!(:welcome_message) { create(:automatic_answer, :welcome, :messenger, retailer: retailer) }

      it 'returns it' do
        expect(retailer.messenger_welcome_message).to be_an_instance_of(AutomaticAnswer)
      end
    end

    context 'when the retailer does not have a messenger active welcome message configured' do
      it 'returns nil' do
        expect(retailer.messenger_welcome_message).to be nil
      end
    end
  end

  describe '#messenger_inactive_message' do
    subject(:retailer) { create(:retailer) }

    context 'when the retailer has a messenger inactive message configured' do
      let!(:inactive_message) { create(:automatic_answer, :inactive, :messenger, retailer: retailer) }

      it 'returns it' do
        expect(retailer.messenger_inactive_message).to be_an_instance_of(AutomaticAnswer)
      end
    end

    context 'when the retailer does not have a messenger inactive message configured' do
      it 'returns nil' do
        expect(retailer.messenger_inactive_message).to be nil
      end
    end
  end

  describe '#retailer_user_connected_to_fb' do
    let(:retailer) { create(:retailer) }
    let!(:retailer_user) { create(:retailer_user, retailer: retailer) }

    context 'when it is connected to facebook' do
      let!(:retailer_user_fb) { create(:retailer_user, :from_fb, retailer: retailer) }

      it 'returns the retailer user with the credentials' do
        expect(retailer.retailer_user_connected_to_fb).to eq(retailer_user_fb)
      end
    end

    context 'when it is not connected to facebook' do
      it 'returns nil' do
        expect(retailer.retailer_user_connected_to_fb).to be nil
      end
    end
  end

  describe '#gupshup_src_name_to_nil' do
    context 'when the gupshup src name is given' do
      let(:retailer) { create(:retailer, gupshup_src_name: 'MercatelyTest') }

      it 'saves the attribute as it comes' do
        expect(retailer.gupshup_src_name).to eq('MercatelyTest')
      end
    end

    context 'when the gupshup src name is blank' do
      let(:retailer) { create(:retailer, gupshup_src_name: '') }

      it 'saves the attribute as nil' do
        expect(retailer.gupshup_src_name).to be nil
      end
    end
  end

  describe '#karix_integrated?' do
    context 'when it does not have whatsapp enabled' do
      let(:retailer) do
        create(:retailer, whats_app_enabled: false, karix_whatsapp_phone: '+593123456789', karix_account_uid:
          'MyKarixAccount', karix_account_token: 'MyKarixToken')
      end

      it 'returns false' do
        expect(retailer.karix_integrated?).to be false
      end
    end

    context 'when it does not have a whatsapp phone' do
      let(:retailer) do
        create(:retailer, whats_app_enabled: true, karix_whatsapp_phone: nil, karix_account_uid:
          'MyKarixAccount', karix_account_token: 'MyKarixToken')
      end

      it 'returns false' do
        expect(retailer.karix_integrated?).to be false
      end
    end

    context 'when it does not have a karix account uid' do
      let(:retailer) do
        create(:retailer, whats_app_enabled: true, karix_whatsapp_phone: '+593123456789', karix_account_uid:
          nil, karix_account_token: 'MyKarixToken')
      end

      it 'returns false' do
        expect(retailer.karix_integrated?).to be false
      end
    end

    context 'when it does not have a karix account token' do
      let(:retailer) do
        create(:retailer, whats_app_enabled: true, karix_whatsapp_phone: '+593123456789', karix_account_uid:
          'MyKarixAccount', karix_account_token: nil)
      end

      it 'returns false' do
        expect(retailer.karix_integrated?).to be false
      end
    end

    context 'when it has all the required attributes' do
      let(:retailer) do
        create(:retailer, whats_app_enabled: true, karix_whatsapp_phone: '+593123456789', karix_account_uid:
          'MyKarixAccount', karix_account_token: 'MyKarixToken')
      end

      it 'returns true' do
        expect(retailer.karix_integrated?).to be true
      end
    end
  end

  describe '#whatsapp_integrated?' do
    context 'when the retailer is not karix or gupshup integrated' do
      let(:retailer) { create(:retailer) }

      it 'returns false' do
        expect(retailer.whatsapp_integrated?).to be false
      end
    end

    context 'when the retailer is karix integrated' do
      let(:retailer) { create(:retailer, :karix_integrated) }

      it 'returns true' do
        expect(retailer.whatsapp_integrated?).to be true
      end
    end

    context 'when the retailer is gupshup integrated' do
      let(:retailer) { create(:retailer, :gupshup_integrated) }

      it 'returns true' do
        expect(retailer.whatsapp_integrated?).to be true
      end
    end
  end

  describe '#main_paymentez_credit_card' do
    it 'returns the main credit card' do
      create_list(:paymentez_credit_card, 2, retailer: retailer)

      main_card = retailer.paymentez_credit_cards.first
      expect(retailer.main_paymentez_credit_card).to eq(main_card)
    end

    it 'returns the nil if no main credit card is set' do
      create_list(:paymentez_credit_card, 2, retailer: retailer)
      retailer.paymentez_credit_cards.first.update(main: false)

      expect(retailer.main_paymentez_credit_card).to eq(nil)
    end
  end

  describe '#available_customer_tags' do
    context 'when customer_id is an argument' do
      let(:customer) { create(:customer, retailer: retailer) }
      let(:tag) { create(:tag, retailer: retailer, tag: 'Prueba 1') }
      let!(:tag2) { create(:tag, retailer: retailer, tag: 'Prueba 2') }
      let!(:customer_tag) { create(:customer_tag, tag: tag, customer: customer) }

      it 'returns the retailer tags except the ones already assigned to the customer' do
        expect(retailer.available_customer_tags(customer.id).size).to eq(1)
        expect(retailer.available_customer_tags(customer.id).first.tag).to eq('Prueba 2')
      end
    end

    context 'when customer_id is not an argument' do
      let!(:tag) { create(:tag, retailer: retailer) }
      let!(:tag2) { create(:tag, retailer: retailer) }

      it 'returns all the retailer tags' do
        expect(retailer.available_customer_tags.size).to eq(2)
      end
    end
  end

  describe '#add_sales_channel' do
    context 'when a retailer is created/updated' do
      context 'when it is not whatsapp integrated' do
        let(:retailer_not_integrated) { build(:retailer) }

        it 'does not create a whatsapp sales channel' do
          retailer_not_integrated.save

          retailer_not_integrated.reload
          expect(retailer_not_integrated.sales_channels.size).to eq(0)
        end
      end

      context 'when it is whatsapp integrated' do
        context 'when does not exist the sales channel yet' do
          let(:retailer_integrated) { build(:retailer, :karix_integrated) }

          it 'creates a whatsapp sales channel' do
            retailer_integrated.save

            retailer_integrated.reload
            expect(retailer_integrated.sales_channels.size).to eq(1)
            expect(retailer_integrated.sales_channels.first.channel_type).to eq('whatsapp')
          end
        end

        context 'when the sales channel already exists' do
          let(:retailer_integrated) { create(:retailer, :karix_integrated) }

          it 'does not create a whatsapp sales channel' do
            expect(retailer_integrated.sales_channels.size).to eq(1)
            expect(retailer_integrated.sales_channels.first.channel_type).to eq('whatsapp')

            retailer_integrated.update(name: 'Test')

            retailer_integrated.reload
            expect(retailer_integrated.sales_channels.size).to eq(1)
          end
        end
      end
    end
  end

  describe '#refund_message_cost' do
    let(:retailer) { create(:retailer, ws_balance: 15.0) }

    it 'adds the amount passed to the ws balance' do
      expect(retailer.ws_balance).to eq(15.0)
      retailer.refund_message_cost(0.5)
      expect(retailer.reload.ws_balance).to eq(15.5)
    end
  end
end
