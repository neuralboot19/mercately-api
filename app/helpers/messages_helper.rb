module MessagesHelper
  def total_unread
    # quantity_unread_messages + quantity_unread_questions
    0
  end

  def quantity_unread_messages
    # current_retailer.unread_messages.size
    0
  end

  def facebook_unread_messages
    # current_retailer.facebook_retailer&.facebook_unread_messages(current_retailer_user)&.size
    0
  end

  def instagram_unread_messages
    # current_retailer.facebook_retailer&.instagram_unread_messages(current_retailer_user)&.size
    0
  end

  def quantity_unread_questions
    # current_retailer.unread_questions.size
    0
  end

  def whatsapp_unread_messages
    # integration_service = "#{current_retailer.karix_integrated? ? 'karix' : 'gupshup'}_unread_whatsapp_messages"
    # current_retailer.send(integration_service, current_retailer_user).size
    0
  end
end
