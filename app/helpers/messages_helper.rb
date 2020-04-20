module MessagesHelper
  def total_unread
    quantity_unread_messages + quantity_unread_questions
  end

  def quantity_unread_messages
    current_retailer.unread_messages.size
  end

  def facebook_unread_messages
    current_retailer.facebook_retailer&.facebook_unread_messages&.size
  end

  def quantity_unread_questions
    current_retailer.unread_questions.size
  end

  def whatsapp_unread_messages
    total = current_retailer.karix_unread_whatsapp_messages(current_retailer_user).size
    total > 9 ? '9+' : total
  end
end
