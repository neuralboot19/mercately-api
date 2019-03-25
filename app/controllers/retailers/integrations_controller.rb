class Retailers::IntegrationsController < RetailersController
  before_action :set_ml, only: [:connect_to_ml]

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

  private

    def get_ml_access_token(code)
      @ml.get_access_token_from_url(code)
    end

    def set_ml
      @ml = MercadoLibre.new(@retailer)
    end
end
