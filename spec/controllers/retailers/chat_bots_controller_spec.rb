require 'rails_helper'

RSpec.describe 'ChatBotsController', type: :request do
  let(:retailer) { create(:retailer, :with_chat_bots) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }

  describe 'GET #tree_options' do
    before do
      sign_in retailer_user
    end

    context 'when the retailer is not the owner of the chat bot' do
      let(:chat_bot) { create(:chat_bot) }

      it 'redirects to dashboard' do
        get retailers_chat_bot_tree_options_path(chat_bot)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to("/retailers/#{retailer.slug}/dashboard")
      end
    end

    context 'when the retailer is owner of the chat bot' do
      let(:chat_bot) { create(:chat_bot, retailer: retailer) }

      context 'when the chat bot does not have options' do
        it 'responses nil' do
          get retailers_chat_bot_tree_options_path(chat_bot)

          json = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(json['options']).to be_nil
        end
      end

      context 'when the chat bot has options' do
        let(:root_option) { create(:chat_bot_option, chat_bot: chat_bot, text: 'Root node') }
        let!(:children_options) { create_list(:chat_bot_option, 2, chat_bot: chat_bot, parent: root_option) }
        let!(:deleted_option) { create(:chat_bot_option, :deleted, chat_bot: chat_bot, parent: root_option) }

        it 'returns only the active options' do
          get retailers_chat_bot_tree_options_path(chat_bot)

          json = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(json['options'].count).to eq(1)
          expect(json['options'].first['children'].size).to eq(2)
        end
      end
    end
  end

  describe 'POST #delete_chat_bot_option' do
    before do
      sign_in retailer_user
    end

    let(:chat_bot) { create(:chat_bot, retailer: retailer) }
    let!(:root_option) { create(:chat_bot_option, chat_bot: chat_bot, text: 'Root node') }
    let!(:first_child) { create(:chat_bot_option, chat_bot: chat_bot, parent: root_option) }
    let!(:second_child) { create(:chat_bot_option, chat_bot: chat_bot, parent: root_option) }

    context 'HTML' do
      context 'when the option is the root' do
        it 'does not soft delete the option' do
          post retailers_chat_bot_delete_chat_bot_option_path(retailer, chat_bot), params: { option_id: root_option.id }

          expect(ChatBotOption.active.count).to eq(3)
          expect(flash[:notice]).to match('No puedes eliminar esta opción.')
          expect(response).to redirect_to(
            "/retailers/#{retailer.slug}/chat_bots/#{chat_bot.web_id}/list_chat_bot_options"
          )
        end
      end

      context 'when the option is not the root' do
        context 'when the option allows the deletion' do
          it 'does soft delete the option' do
            post retailers_chat_bot_delete_chat_bot_option_path(retailer, chat_bot), params: { option_id: first_child.id }

            expect(ChatBotOption.active.count).to eq(2)
            expect(flash[:notice]).to match('Opción eliminada con éxito.')
            expect(response).to redirect_to(
              "/retailers/#{retailer.slug}/chat_bots/#{chat_bot.web_id}/list_chat_bot_options"
            )
          end
        end

        context 'when the option does not allow the deletion' do
          it 'does not soft delete the option' do
            post retailers_chat_bot_delete_chat_bot_option_path(retailer, chat_bot), params: { option_id: 0 }

            expect(ChatBotOption.active.count).to eq(3)
            expect(flash[:notice]).to match('Error al eliminar la opción.')
            expect(response).to redirect_to(
              "/retailers/#{retailer.slug}/chat_bots/#{chat_bot.web_id}/list_chat_bot_options"
            )
          end
        end
      end
    end

    context 'JSON' do
      context 'when the option is the root' do
        it 'does not soft delete the option' do
          post retailers_chat_bot_delete_chat_bot_option_path(retailer, chat_bot), params:
            { option_id: root_option.id, format: :json }

          json = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(json['message']).to eq('No puedes eliminar esta opción.')
          expect(ChatBotOption.active.count).to eq(3)
        end
      end

      context 'when the option is not the root' do
        context 'when the option allows the deletion' do
          it 'does soft delete the option' do
            post retailers_chat_bot_delete_chat_bot_option_path(retailer, chat_bot), params:
              { option_id: first_child.id, format: :json }

            json = JSON.parse(response.body)
            expect(response).to have_http_status(:ok)
            expect(json['message']).to eq('Opción eliminada con éxito.')
            expect(ChatBotOption.active.count).to eq(2)
          end
        end

        context 'when the option does not allow the deletion' do
          it 'does not soft delete the option' do
            post retailers_chat_bot_delete_chat_bot_option_path(retailer, chat_bot), params:
              { option_id: 0, format: :json }

            json = JSON.parse(response.body)
            expect(response).to have_http_status(:ok)
            expect(json['message']).to eq('Error al eliminar la opción.')
            expect(ChatBotOption.active.count).to eq(3)
          end
        end
      end
    end
  end
end
