class Retailers::StatsController < RetailersController
  include StatsControllerConcern

  def total_messages_stats
    if params[:search] && params[:search][:range].present?
      @start_date, @end_date = params[:search][:range].split(' - ')

      @start_date = current_retailer.show_stats ? Date.parse(@start_date) : Date.today - 4.days
      @end_date = current_retailer.show_stats ? Date.parse(@end_date) : Date.today
    else
      @start_date = Date.today - 4.days
      @end_date = Date.today
    end

    @start_date = @start_date.strftime('%d/%m/%Y')
    @end_date = @end_date.strftime('%d/%m/%Y 23:59:59')

    @cast_start_date = Time.parse(@start_date)
    @cast_end_date = Time.parse(@end_date)

    total_count_messages
  end
end
