module ApplicationHelper
  def show_date(date)
    date.strftime("%k:%M %d-%b-%Y")
  end
end
