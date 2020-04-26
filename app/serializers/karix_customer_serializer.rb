class KarixCustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone, :address, :city, :state, :zip_code, :id_number,
             :karix_unread_message?, :recent_inbound_message_date, :assigned_agent, :last_whatsapp_message

  def karix_unread_message?
    object.karix_unread_message?
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
end
