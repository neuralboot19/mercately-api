module ApplicationHelper
  def show_date(date)
    if Time.now.year > date.year
      "#{date.day} - #{date.strftime('%b')} - #{date.year} (hace #{time_ago_in_words(date)})"
    else
      "#{date.day} - #{date.strftime('%b')} (hace #{time_ago_in_words(date)})"
    end
  end
end
