class Retailers::IntegrationsController < RetailersController
  skip_before_action :authenticate_retailer_user!, except: [:index, :connect_to_ml, :connect_to_hubspot]
  skip_before_action :verify_authenticity_token, except: [:index, :connect_to_ml, :connect_to_hubspot]
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

  def connect_to_hubspot
    Hubspot.configure({
      client_id: ENV['HUBSPOT_CLIENT'],
      client_secret: ENV['HUBSPOT_CLIENT_SECRET'],
      redirect_uri: ENV['HUBSPOT_REDIRECT_URL']
    })
    token = Hubspot::OAuth.create(params[:code])
    hs = HubspotService::Api.new(token['access_token'])
    hs_id = hs.me['portalId']
    current_retailer.update(
      hs_expires_in: token['expires_in'].seconds.from_now,
      hs_access_token: token['access_token'],
      hs_refresh_token: token['refresh_token'],
      hs_id: hs_id
    )
    redirect_to retailers_hubspot_index_path(current_retailer)
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
    render(status: 200, json: params['hub.challenge']) && return if params['hub.challenge']

    message_data = begin
                     params['entry'][0]['messaging'][0]
                   rescue
                     params['entry'][0]['message'][0]
                   end
    platform = params['object']
    uid = message_data['recipient']['id']
    if platform != 'instagram'
      platform = 'messenger'
      finder = { uid: uid }
    else
      finder = { instagram_uid: uid }
    end
    facebook_retailer = FacebookRetailer.find_by(finder)
    render(status: 200, json: {}) && return if facebook_retailer.blank?

    facebook_service = Facebook::Messages.new(facebook_retailer, platform)
    save_facebook_message(facebook_service, message_data)
    save_postback_button_interaction(facebook_service, message_data)
    import_facebook_message(facebook_service, message_data)
    read_facebook_message(facebook_service, message_data, platform)

    render status: 200, json: {}
  end

  private

    def save_access_token(response)
      response = JSON.parse(response.body)

      if MeliRetailer.check_unique_meli_user_id(response['user_id'])
        redirect_to retailers_integrations_path(@retailer.slug), notice:
          'Esta cuenta de MercadoLibre ya ha sido conectada'
      else
        @ml.save_access_token(response)
        # Products::ImportProductsJob.perform_later(@retailer.id) if @retailer.meli_retailer
        redirect_to retailers_integrations_path(@retailer.slug), notice: 'Conectado existosamente'
      end
    end

    def get_ml_access_token(code)
      @ml.get_access_token_from_url(code)
    end

    def set_ml
      @ml = MercadoLibre::Auth.new(@retailer)
    end

    def save_facebook_message(facebook_service, message_data)
      return unless message_data['message']&.[]('text') || message_data['message']&.[]('attachments')

      facebook_service.save(message_data)
    end

    def import_facebook_message(facebook_service, message_data)
      return unless message_data['delivery']&.[]('mids')

      psid = message_data['sender']['id']
      facebook_service.import_delivered(message_data['delivery']['mids'][0], psid)
    end

    def read_facebook_message(facebook_service, message_data, platform)
      return if message_data['read']&.[]('watermark').blank? && platform == 'messenger'

      psid = message_data['sender']['id']
      facebook_service.mark_read(psid)
    end

    def save_postback_button_interaction(facebook_service, message_data)
      return unless message_data['postback']&.[]('payload')

      facebook_service.save_postback_interaction(message_data)
    end
end
