module ApplicationHelper
  def show_date(date)
    date&.strftime('%k:%M %d-%b-%Y')
  end

  def date_from_parameters
    params[:search][:dob] if params[:search].present?
  end

  def show_date_without_hour(date)
    date&.strftime('%d-%b-%Y')
  end
end
