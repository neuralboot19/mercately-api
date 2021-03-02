module Retailers::Api::V1
  class WhatsappConversationsController < Retailers::Api::V1::ApiController
    def whatsapp_conversations
      conversations = GupshupWhatsappMessage.select("COUNT(gsm.id) as message_count, MAX(gsm.created_at) as last_interaction, gsm.customer_id, c.first_name,
        c.last_name, c.email, c.phone, ru.id as agent_id")
        .joins("LEFT JOIN customers c on c.id = gsm.customer_id ")
        .joins("LEFT JOIN agent_customers ac ON ac.customer_id = c.id")
        .joins("LEFT JOIN retailer_users ru ON ru.id = ac.retailer_user_id")
        .where("gsm.retailer_id= #{current_retailer.id}").from("gupshup_whatsapp_messages gsm")
        .group("gsm.customer_id, c.first_name, c.last_name, c.email, c.phone, ru.id")
        .order("last_interaction DESC")

      if params[:unassigned] == true || params[:unassigned] == "true"
        conversations = conversations.where("ac.retailer_user_id IS NULL")
      end

      results = conversations.length
      page = params[:page] ? params[:page] : 1
      per_page = params[:results_per_page] ? params[:results_per_page] : 100
      total_pages = (results / per_page.to_i) + 1

      conversations = conversations.page(page.to_i).per(per_page)

      render status: 200, json: {
        results: results,
        total_pages: total_pages,
        whatsapp_conversations: conversations,
      }
    end
  end
end
