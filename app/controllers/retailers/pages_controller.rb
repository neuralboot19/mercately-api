class Retailers::PagesController < RetailersController
  include PagesControllerConcern

  def dashboard
    if params[:search] && params[:search][:range].present?
      @start_date, @end_date = params[:search][:range].split(' - ')
    else
      @start_date = Date.today.beginning_of_month.strftime('%d/%m/%Y')
      @end_date = Date.today.strftime('%d/%m/%Y')
    end

    general_info
    best_sold_products
    best_categories
    best_clients
  end
end
