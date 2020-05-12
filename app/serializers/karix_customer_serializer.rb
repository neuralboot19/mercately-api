class KarixCustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone, :address, :city, :state, :zip_code, :id_number,
             :unread_whatsapp_message?, :recent_inbound_message_date, :assigned_agent, :last_whatsapp_message,
             :recent_message_date, :handle_message_events?

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
end
