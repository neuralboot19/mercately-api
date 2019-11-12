module ApplicationHelper
  def show_date(date)
    date.strftime('%k:%M %d-%b-%Y')
  end

  def show_date_without_hour(date)
    date.strftime('%d-%b-%Y')
  end
end
