module CounterMessagesConcern
  extend ActiveSupport::Concern

  included do
    after_commit :increase_unread_counter, on: :create
  end

  private

    def increase_unread_counter
      return if direction != 'inbound'

      update_chat_counter = customer.count_unread_messages.zero?
      update_sql = if update_chat_counter
                     'whatsapp_unread = TRUE, unread_whatsapp_chats_count = unread_whatsapp_chats_count + 1'
                   else
                     'whatsapp_unread = TRUE'
                   end
      customer.update_column(:count_unread_messages, customer.count_unread_messages + 1)

      admins_supervisors = retailer.admins.or(retailer.supervisors)
      admins_supervisors.update_all(update_sql)

      agent = customer.agent
      return if agent && !agent.agent?

      if agent.present?
        counter = if update_chat_counter
                    agent.unread_whatsapp_chats_count + 1
                  else
                    agent.unread_whatsapp_chats_count
                  end
        agent.update_columns(
          whatsapp_unread: true,
          unread_whatsapp_chats_count: counter
        )
      else
        retailer.retailer_users.active_agents.where(only_assigned: false).update_all(update_sql)
      end
    rescue StandardError => e
      Rails.logger.error(e)
      SlackError.send_error(e)
    end
end
