class Retailers::PagesController < RetailersController
  include PagesControllerConcern
  layout 'chats/chat'
  before_action :set_prismic_variables

  def dashboard
    @start_date = Date.today.beginning_of_week.strftime('%d/%m/%Y')
    @end_date = Date.today.strftime('%d/%m/%Y')

    unless current_retailer_user.first_name.present? && current_retailer_user.last_name.present?
      flash[:alert] = "Usted no tiene un Nombre y/o Apellido registrado, \
                       por favor, actualice sus datos \
                       <a href='#{edit_retailer_info_path(current_retailer)}'>aquí</a>".html_safe
    end

    @wa_msgs_count = RetailerAmountMessage
      .where(created_at: @start_date..@end_date, retailer: current_retailer)
      .sum(:total_ws_messages)

    @documents = begin
                   api = Prismic.api(@url, @token)
                   response = api.query(
                     Prismic::Predicates.at('document.type', 'blogentry'),
                     'pageSize' => 3,
                     'page' => 1,
                     'orderings' => '[document.first_publication_date desc]'
                   )
                   response.results
                 rescue StandardError
                   [].freeze
                 end

    general_info
    best_sold_products
    best_categories
    best_clients
  end

  private

    def set_prismic_variables
      @url = ENV['PRISMIC_URL']
      @token = ENV['PRISMIC_TOKEN']
    end
end
