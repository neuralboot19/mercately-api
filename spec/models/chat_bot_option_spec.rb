require 'rails_helper'

RSpec.describe ChatBotOption, type: :model do
  subject(:chat_bot_option) { create(:chat_bot_option, chat_bot: chat_bot) }

  let(:retailer) { create(:retailer) }
  let(:chat_bot) { create(:chat_bot, retailer: retailer) }

  describe '#check_destroy_requirements' do
    it 'avoids deleting the option' do
      expect { chat_bot_option.send(:check_destroy_requirements) }.to throw_symbol(:abort)
    end
  end

  describe '#update_descendants_on_delete' do
    before do
      create_list(:chat_bot_option, 2, chat_bot: chat_bot, parent: chat_bot_option)
    end

    context 'when the option is not soft deleted' do
      it 'does not soft delete its descendants' do
        chat_bot_option.send(:update_descendants_on_delete)

        expect(chat_bot_option.descendants.active.count).to eq(2)
      end
    end

    context 'when the option is soft deleted' do
      it 'does soft delete its descendants' do
        chat_bot_option.option_deleted = true
        chat_bot_option.send(:update_descendants_on_delete)

        expect(chat_bot_option.descendants.active.count).to eq(0)
      end
    end
  end
end
