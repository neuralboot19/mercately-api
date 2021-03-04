module Retailers::Api::V1
  class MessengerConversationsController < Retailers::Api::V1::ApiController
    def messenger_conversations
      unless current_retailer.facebook_retailer
        render status: 200, json: {
          results: 0,
          total_pages: 0,
          messenger_conversations: 0
        }

        return
      end

      conversations = current_retailer.facebook_retailer.facebook_messages
        .select('COUNT(facebook_messages.id) as message_count, MAX(facebook_messages.created_at) as last_interaction,
          facebook_messages.customer_id, c.first_name, c.last_name, c.email, ru.id as agent_id')
        .joins('LEFT JOIN customers c on c.id = facebook_messages.customer_id')
        .joins('LEFT JOIN agent_customers ac ON ac.customer_id = c.id')
        .joins('LEFT JOIN retailer_users ru ON ru.id = ac.retailer_user_id')
        .group('facebook_messages.customer_id, c.first_name, c.last_name, c.email, ru.id')
        .order('last_interaction DESC')

      if params[:unassigned] == true || params[:unassigned] == 'true'
        conversations = conversations.where('ac.retailer_user_id IS NULL')
      end

      results = conversations.length
      page = params[:page] ? params[:page] : 1
      per_page = params[:results_per_page] ? params[:results_per_page] : 100
      total_pages = (results / per_page.to_i) + 1

      conversations = conversations.page(page.to_i).per(per_page)

      render status: 200, json: {
        results: results,
        total_pages: total_pages,
        messenger_conversations: conversations
      }
    end
  end
end
