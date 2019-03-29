class Retailers::IntegrationsController < RetailersController
  before_action :set_ml, only: [:connect_to_ml]
  before_action :set_ml_products, only: [:mercadolibre_import]

  def index
  end

  def connect_to_ml
    response = get_ml_access_token(params[:code])
    if response.status == 200
      @ml.save_access_token(JSON.parse(response.body))
      MercadoLibre::Retailer.new(@retailer).update_retailer_info
      redirect_to retailers_integrations_path(@retailer.slug), notice: 'Conectado existosamente'
    else
      redirect_to retailers_integrations_path(@retailer.slug), notice: 'Error al conectarse'
    end
  end

  def mercadolibre_import
    @ml_products.search_items
    redirect_to retailers_integrations_path(@retailer.slug), notice: 'Productos han comenzado a importarse'
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
