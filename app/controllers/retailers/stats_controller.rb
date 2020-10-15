class Retailers::StatsController < RetailersController
  include StatsControllerConcern
  include StatsProspectsConcern
  include StatsAgentsConcern
  include StatsChatsConcern

  before_action :check_role_access

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

    @integration, @status, @model = if current_retailer.karix_integrated?
                                      ['karix_whatsapp_messages', 'failed', KarixWhatsappMessage]
                                    elsif current_retailer.gupshup_integrated?
                                      ['gupshup_whatsapp_messages', 'error', GupshupWhatsappMessage]
                                    end

    total_count_messages
    total_prospects_vs_currents
    total_agents_performance
    total_chats_answered
  end

  private

    def check_role_access
      return if current_retailer_user.admin? || current_retailer_user.supervisor?

      redirect_to retailers_dashboard_path(current_retailer)
    end
end
