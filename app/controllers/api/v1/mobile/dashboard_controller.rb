class Api::V1::Mobile::DashboardController < Api::MobileController
  include PagesControllerConcern
  before_action :set_prismic_variables
  before_action :set_retailer

  def index
    @start_date = Date.today.beginning_of_week.beginning_of_day
    @end_date = Time.now
    @start_date_format = @start_date.strftime('%d/%m/%Y %H:%M:%S')
    @end_date_format = @end_date.strftime('%d/%m/%Y %H:%M:%S')

    messages_count = RetailerAmountMessage
      .where(created_at: @start_date..@end_date, retailer: @user.retailer)
      .sum(:total_ws_messages)

    news = begin
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
    clients

    render status: 200, json: {
      messages_count: messages_count,
      start_date: @start_date_format,
      end_date: @end_date_format,
      best_clients_count: @clients.length,
      best_sold_products: @best_products,
      first_five_orders: @first_five_orders,
      success_orders_count: @success_orders_count,
      ml_integrated: @user.retailer.ml_integrated?,
      whatsapp_integrated: @user.retailer.whatsapp_integrated?,
      facebook_integrated: @user.retailer.facebook_integrated?,
      instagram_integrated: @user.retailer.instagram_integrated?,
      news: news
    }
  end

  private

    def set_retailer
      @user = RetailerUser.find_by_email(request.headers['email'] || create_params[:email])
      return record_not_found unless @user

      @retailer = @user.retailer
      @user
    end

    def set_prismic_variables
      @url = ENV['PRISMIC_URL']
      @token = ENV['PRISMIC_TOKEN']
    end
end
