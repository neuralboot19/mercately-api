class Retailers::FacebookCatalogsController < RetailersController
  before_action :set_facebook_catalog, only: :save_selected_catalog

  def select_catalog
    if current_retailer.facebook_catalog.blank?
      redirect_to root_path
      return
    end

    unless current_retailer.facebook_catalog.connected?
      businesses = facebook_api.businesses
      unless businesses&.[]('data')
        redirect_to retailers_integrations_path(current_retailer), notice:
          'Hubo un problema en la integración del Catálogo de Facebook.'
        return
      end

      businesses['data'].each do |business|
        catalogs = facebook_api.business_product_catalogs(business['id'])
        business['catalogs'] = catalogs&.[]('data') || []
      end

      @businesses = businesses
    end
  end

  def save_selected_catalog
    if @facebook_catalog.update(uid: params[:uid], name: params[:name], business_id:
      params[:business_id])
      redirect_to root_path, notice: 'Catálogo de Facebook asociado con éxito'
    else
      redirect_to retailers_select_catalog_path(current_retailer), notice:
        'Error: El negocio o catálogo seleccionado ya está asociado a una cuenta de Mercately'
    end
  end

  private

    def facebook_api
      @facebook_api = Facebook::Api.new(current_retailer.facebook_retailer, current_retailer.retailer_user_connected_to_fb)
    end

    def set_facebook_catalog
      @facebook_catalog = current_retailer.facebook_catalog
    end
end
