class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :psid, :email, :phone, :address, :city, :state, :zip_code, :id_number,
             :unread_message?, :recent_message_date

  def unread_message?
    object.unread_message?
  end

  def recent_message_date
    object.recent_facebook_message_date
  end
end
