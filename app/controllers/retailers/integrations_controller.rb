class Retailers::IntegrationsController < RetailersController
  skip_before_action :authenticate_retailer_user!, only: :callbacks
  skip_before_action :verify_authenticity_token, only: :callbacks
  before_action :set_ml, only: [:connect_to_ml]
  before_action :set_ml_products, only: [:mercadolibre_import]

  def index
  end

  def connect_to_ml
    response = get_ml_access_token(params[:code])
    if response.status == 200
      @ml.save_access_token(JSON.parse(response.body))
      redirect_to retailers_integrations_path(@retailer.slug), notice: 'Conectado existosamente'
    else
      redirect_to retailers_integrations_path(@retailer.slug), notice: 'Error al conectarse'
    end
  end

  def mercadolibre_import
    @ml_products.search_items
    redirect_to retailers_integrations_path(@retailer.slug), notice: 'Productos han comenzado a importarse'
  end

  def callbacks
    @retailer = MeliRetailer.find_by(meli_user_id: params[:user_id])&.retailer
    if @retailer
      case params[:topic]
      when 'orders_v2'
        order_id = params[:resource].scan(/\d/).join
        MercadoLibre::Orders.new(@retailer).import(order_id)
        render status: '200', json: { message: 'Success' }.to_json
      when 'items'
        product_id = params[:resource].split('/').last
        MercadoLibre::Products.new(@retailer).pull_update(product_id)
        render status: '200', json: { message: 'Success' }.to_json
      when 'questions'
        question_id = params[:resource].scan(/\d/).join
        MercadoLibre::Questions.new(@retailer).import(question_id)
        render status: '200', json: { message: 'Success' }.to_json
      else
        render status: '404', json: { message: "#{params[:topic]} topic not found" }.to_json
        Raven.capture_message "#{params[:topic]} topic not found"
      end
    else
      render status: '404', json: { message: 'Retailer not found' }.to_json
    end
  end

  private

    def get_ml_access_token(code)
      @ml.get_access_token_from_url(code)
    end

    def set_ml
      @ml = MercadoLibre::Auth.new(@retailer)
    end

    def set_ml_products
      @ml_products = MercadoLibre::Products.new(@retailer)
    end
end
