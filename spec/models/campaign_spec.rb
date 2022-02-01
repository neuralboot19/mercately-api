require 'rails_helper'

RSpec.describe Campaign, type: :model do
  subject(:campaign) { build(:campaign, :with_sent_messages, send_at: Time.new(2022, 02, 01, 15, 40, 00)) }

  let(:service_response) { { code: '202' } }

  before do
    allow_any_instance_of(Whatsapp::Gupshup::V1::Outbound::Users).to receive(:opt_in).and_return(service_response)
    campaign.save!
  end

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to belong_to(:contact_group) }
    it { is_expected.to belong_to(:whatsapp_template) }
    it { is_expected.to have_many(:gupshup_whatsapp_messages) }
    it { is_expected.to have_many(:karix_whatsapp_messages) }
  end

  describe '#cost' do
    it 'returns 0 if campaign not sent' do
      expect(campaign.cost).to eq 0
    end

    context 'when campaign sent' do
      it 'calculates the real campaign\'s cost' do
        campaign.sent!
        expect(campaign.cost).to eq(campaign.gupshup_whatsapp_messages.sum(:cost))
      end
    end
  end

  describe '#estimated_cost' do
    describe 'when retailer is gupshup integrated' do
      context 'when campaign is sent before February' do
        it 'calculates the campaign estimated cost' do
          campaign.update(send_at: Time.new(2022, 01, 30))

          expect(campaign.estimated_cost).to eq(campaign.contact_group.customers.sum(:ws_notification_cost))
        end
      end

      context 'when retailer has free chats yet' do
        context 'when free chats are less than campaign customers' do
          it 'calculates the campaign estimated cost' do
            allow_any_instance_of(Retailer).to receive(:remaining_free_conversations).and_return(0)

            expect(campaign.estimated_cost).to eq(campaign.contact_group.customers.sum(:ws_bic_cost))
          end
        end

        context 'when free chats are more than campaign customers' do
          it 'calculates the campaign estimated cost' do
            expect(campaign.estimated_cost).to eq(0)
          end
        end
      end

      context 'when retailer does not have free chats' do
        it 'calculates the campaign estimated cost' do
          allow_any_instance_of(Retailer).to receive(:remaining_free_conversations).and_return(0)

          expect(campaign.estimated_cost).to eq(campaign.contact_group.customers.sum(:ws_bic_cost))
        end
      end
    end

    describe 'when retailer is karix integrated' do
      let(:karix_retailer) { create(:retailer, :karix_integrated) }
      let(:karix_campaign) { build(:campaign, :with_karix_sent_messages, retailer: karix_retailer, status: 'sent') }

      it 'calculates the campaign estimated cost' do
        karix_campaign.reload

        expect(karix_campaign.estimated_cost).to eq(karix_campaign.contact_group.customers.size * karix_retailer.ws_notification_cost)
      end
    end
  end

  describe '#customer_details_template(customer)' do
    it 'replaces {{\w}} with customer variables' do
      customer = campaign.contact_group.customers.first
      expect(campaign.customer_details_template(customer)).to eq "Hi #{customer.first_name}. Welcome to our WhatsApp. We will be here for any question."
    end

    context 'when not column on customer table' do
      it 'replaces {{\w}} with custom fields data' do
        campaign.update_column(
          :template_text,
          'Hi {{first_name}}. Welcome to our WhatsApp. We will be here for any {{custom_field}}.'
        )
        customer = campaign.contact_group.customers.first
        crd = customer.customer_related_data.create(
          data: 'ask',
          customer_related_field: CustomerRelatedField.new(retailer: campaign.retailer, name: 'custom_field')
        )
        expect(campaign.customer_details_template(customer)).to eq "Hi #{customer.first_name}. Welcome to our WhatsApp. We will be here for any #{crd.data}."
      end

      context 'when customer has no data' do
        it 'replaces {{\w}} with blank space' do
          campaign.update_column(
            :template_text,
            'Hi {{first_name}}. Welcome to our WhatsApp. We will be here for any {{custom_field}}.'
          )
          customer = campaign.contact_group.customers.first
          expect(campaign.customer_details_template(customer)).to eq "Hi #{customer.first_name}. Welcome to our WhatsApp. We will be here for any  ."
        end
      end
    end
  end
end
