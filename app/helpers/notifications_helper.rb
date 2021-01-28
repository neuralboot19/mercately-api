module NotificationsHelper
  def customer_name(customer)
    (customer.full_names.presence || customer.whatsapp_name.presence || customer.phone).truncate(16)
  end

  def chat_type_icon(chat_type)
    case chat_type
    when 'whatsapp'
      'fab fa-whatsapp'
    when 'messenger'
      'fab fa-facebook-messenger'
    else
      'far fa-comment-alt'
    end
  end

  def chat_url(notification)
    case notification.notification_type
    when 'whatsapp'
      retailers_whats_app_chats_path(current_retailer, cid: notification.customer.id)
    when 'messenger'
      retailers_facebook_chats_path(current_retailer, cid: notification.customer.id)
    else
      nil
    end
  end
end
