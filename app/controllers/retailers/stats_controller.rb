class Retailers::StatsController < RetailersController
  include StatsControllerConcern

  def total_messages_stats
    Time.zone = current_time_zone

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

    @cast_start_date = Time.zone.parse(@start_date)
    @cast_end_date = Time.zone.parse(@end_date)

    total_count_messages
  end

  private

    def current_time_zone
      time = Time.now.strftime('%z').gsub('0', '').to_i

      #Esta condicion es necesaria, ya que si el GMT es -4, hay una opcion de primero en ActiveSupport::TimeZone que
      #retorna America/Halifax, la cual es -3, y no toma correctamente los tiempos en los queries.
      time_zone = if time == -4
                    ActiveSupport::TimeZone.all
                    .find { |z| z.utc_offset == (time * 3600).to_i && z.name != 'Atlantic Time (Canada)' }
                  else
                    ActiveSupport::TimeZone[time]
                  end

      time_zone.presence || 'UTC'
    end
end
