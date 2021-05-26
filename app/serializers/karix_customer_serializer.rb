class KarixCustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone, :address, :city, :state, :zip_code,
             :id_number, :whatsapp_name, :unread_whatsapp_chat, :whatsapp_opt_in, :active_bot, :allow_start_bots,
             :tags, :unread_whatsapp_message?, :recent_inbound_message_date, :assigned_agent, :last_whatsapp_message,
             :recent_message_date, :handle_message_events?, :unread_whatsapp_messages, :last_messages

  def unread_whatsapp_message?
    object.unread_whatsapp_message?
  end

  def recent_inbound_message_date
    object.recent_inbound_message_date
  end

  def assigned_agent
    object.assigned_agent
  end

  def last_whatsapp_message
    object.last_whatsapp_message
  end

  def recent_message_date
    object.recent_whatsapp_message_date
  end

  def handle_message_events?
    object.handle_message_events?
  end

  def unread_whatsapp_messages
    object.unread_whatsapp_messages
  end
end
