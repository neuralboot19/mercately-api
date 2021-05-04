require 'rails_helper'

RSpec.describe ChatBot, type: :model do
  subject(:chat_bot) { create(:chat_bot, retailer: retailer) }

  let(:retailer) { create(:retailer) }

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to have_many(:chat_bot_options).dependent(:destroy) }
    it { is_expected.to have_many(:chat_bot_customers).dependent(:destroy) }
    it { is_expected.to have_many(:customers).through(:chat_bot_customers) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:on_failed_attempt).with_values(%i[resend_options send_attempt_message]) }
    it { is_expected.to define_enum_for(:platform).with_values(%i[whatsapp messenger]) }
  end

  describe '#any_interaction_unique' do
    context 'when is a Messenger Bot' do
      before do
        chat_bot.update(platform: :messenger)
      end

      context 'when there is not other bot with any interaction' do
        let(:other_bot) { build(:chat_bot, :for_messenger, :with_any_interaction, retailer: retailer) }

        it 'activates the bot with any interaction' do
          expect(other_bot.save).to be true
        end
      end

      context 'when there is other bot with any interaction' do
        before do
          chat_bot.update(any_interaction: true)
        end

        let(:other_bot) { build(:chat_bot, :for_messenger, :with_any_interaction, retailer: retailer) }

        it 'does not activate the bot with any interaction' do
          expect(other_bot.save).to be false
          expect(other_bot.errors[:base]).to include('Ya existe un ChatBot activado con cualquier interacción')
        end
      end
    end

    context 'when is a WhatsApp Bot' do
      before do
        chat_bot.update(platform: :whatsapp)
      end

      context 'when there is not other bot with any interaction' do
        let(:other_bot) { build(:chat_bot, :for_whatsapp, :with_any_interaction, retailer: retailer) }

        it 'activates the bot with any interaction' do
          expect(other_bot.save).to be true
        end
      end

      context 'when there is other bot with any interaction' do
        before do
          chat_bot.update(any_interaction: true)
        end

        let(:other_bot) { build(:chat_bot, :for_whatsapp, :with_any_interaction, retailer: retailer) }

        it 'does not activate the bot with any interaction' do
          expect(other_bot.save).to be false
          expect(other_bot.errors[:base]).to include('Ya existe un ChatBot activado con cualquier interacción')
        end
      end
    end
  end
end
