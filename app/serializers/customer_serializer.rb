class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :psid, :email, :phone, :address, :city,
             :state, :zip_code, :id_number, :unread_whatsapp_chat, :unread_message?,
             :recent_message_date, :last_messenger_message, :assigned_agent

  def unread_message?
    object.unread_message?
  end

  def recent_message_date
    object.recent_facebook_message_date
  end

  def last_messenger_message
    object.last_messenger_message
  end

  def assigned_agent
    object.assigned_agent
  end
end
