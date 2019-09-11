module ApplicationHelper
  def show_date(date)
    if Time.now.year > date.year
      "#{date.day} - #{date.strftime('%b')} - #{date.year} (hace #{time_ago_in_words(date)})"
    else
      "#{date.day} - #{date.strftime('%b')} (hace #{time_ago_in_words(date)})"
    end
  end

  def total_unread
    quantity_unread_messages + quantity_unread_questions
  end

  def quantity_unread_messages
    Retailer.messages_total(current_retailer_user.retailer.id)
  end

  def quantity_unread_questions
    Retailer.questions_total(current_retailer_user.retailer.id)
  end
end
