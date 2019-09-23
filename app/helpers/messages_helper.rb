module MessagesHelper
  def total_unread
    quantity_unread_messages + quantity_unread_questions
  end

  def quantity_unread_messages
    Retailer.unread_messages(current_retailer_user.retailer.id).size
  end

  def quantity_unread_questions
    Retailer.unread_questions(current_retailer_user.retailer.id).size
  end
end
