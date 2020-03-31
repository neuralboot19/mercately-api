class Retailers::PagesController < RetailersController
  include PagesControllerConcern

  def dashboard
    if params[:search] && params[:search][:range].present?
      @start_date, @end_date = params[:search][:range].split(' - ')
    else
      @start_date = Date.today.beginning_of_month.strftime('%d/%m/%Y')
      @end_date = Date.today.strftime('%d/%m/%Y')
    end

    unless current_retailer_user.first_name.present? && current_retailer_user.last_name.present?
      flash[:alert] = "Usted no tiene un Nombre y/o Apellido registrado, \
                       por favor, actualice sus datos \
                       <a href='#{edit_retailer_info_path(current_retailer)}'>aquí</a>".html_safe
    end

    general_info
    best_sold_products
    best_categories
    best_clients
  end
end
