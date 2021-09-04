module MessagesHelper
  def ml_total_unread
    current_retailer_user.ml_unread
  end

  def ml_unread_messages
    current_retailer.unread_messages
  end

  def facebook_unread_messages
    current_retailer_user.messenger_unread
  end

  def instagram_unread_messages
    current_retailer_user.instagram_unread
  end

  def ml_unread_questions
    current_retailer.unread_questions
  end

  def whatsapp_unread_messages
    current_retailer_user.whatsapp_unread
  end
end
