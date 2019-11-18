class Retailers::IntegrationsController < RetailersController
  skip_before_action :authenticate_retailer_user!, except: [:index, :connect_to_ml]
  skip_before_action :verify_authenticity_token, except: [:index, :connect_to_ml]
  before_action :set_ml, only: [:connect_to_ml]

  def index
  end

  def connect_to_ml
    response = get_ml_access_token(params[:code])
    if response.status == 200
      save_access_token(response)
    else
      redirect_to retailers_integrations_path(@retailer.slug), notice: 'Error al conectarse'
    end
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
      when 'messages'
        message_id = params[:resource]
        MercadoLibre::Messages.new(@retailer).import(message_id)
        render status: '200', json: { message: 'Success' }.to_json
      else
        render status: '404', json: { message: "#{params[:topic]} topic not found" }.to_json
        Raven.capture_exception "#{params[:topic]} topic not found"
      end
    else
      render status: '404', json: { message: 'Retailer not found' }.to_json
    end
  end

  def messenger_callbacks
    render status: 200, json: params['hub.challenge'] if params['hub.challenge']
  end

  private

    def save_access_token(response)
      response = JSON.parse(response.body)

      if MeliRetailer.check_unique_meli_user_id(response['user_id'])
        redirect_to retailers_integrations_path(@retailer.slug), notice:
          'Esta cuenta de MercadoLibre ya ha sido conectada'
      else
        @ml.save_access_token(response)
        Products::ImportProductsJob.perform_later(@retailer.id) if @retailer.meli_retailer
        redirect_to retailers_integrations_path(@retailer.slug), notice: 'Conectado existosamente'
      end
    end

    def get_ml_access_token(code)
      @ml.get_access_token_from_url(code)
    end

    def set_ml
      @ml = MercadoLibre::Auth.new(@retailer)
    end
end
