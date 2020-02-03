class KarixCustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone, :address, :city, :state, :zip_code, :id_number,
             :karix_unread_message?, :recent_inbound_message_date

  def karix_unread_message?
    object.karix_unread_message?
  end

  def recent_inbound_message_date
    object.recent_inbound_message_date
  end
end
