require 'rails_helper'

RSpec.describe NotificationsHelper, type: :helper do
  describe '#customer_name' do
    let(:customer) { create(:customer) }

    it 'returns customer name truncated to 16 chars' do
      customer_name = helper.customer_name(customer)
      expect(customer_name).to be_a(String)
      expect(customer_name.length).to be <= 16
    end
  end

  describe '#chat_type_icon' do
    context 'when chat type is whatsapp' do
      it 'returns fab fa-whatsapp icon class' do
        expect(helper.chat_type_icon('whatsapp')).to eq('fab fa-whatsapp')
      end
    end

    context 'when chat type is messenger' do
      it 'returns fab fa-facebook-messenger icon class' do
        expect(helper.chat_type_icon('messenger')).to eq('fab fa-facebook-messenger')
      end
    end

    context 'when no chat type is specified' do
      it 'returns far fa-comment-alt icon class' do
        expect(helper.chat_type_icon('any_other_chat_type')).to eq('far fa-comment-alt')
      end
    end
  end
end
