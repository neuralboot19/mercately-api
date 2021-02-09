class Retailers::HubspotController < RetailersController
  def index
    @hubspot_fields = current_retailer.hubspot_fields.not_taken.pluck(:hubspot_field, :id)
    @mapped_field_url = create_mapped_field_retailers_hubspot_index_path(current_retailer.slug)
    @hubspot_field_tag = @hubspot_fields.dup
    @field = current_retailer.customer_hubspot_fields.find_by(customer_field: 'tags')&.hubspot_field
    @hubspot_field_tag.prepend([@field.hubspot_field, @field.id]) if @field
    if current_retailer.hs_tags
      @mapped_field_url = update_mapped_field_retailers_hubspot_index_path(current_retailer.slug, @field.id)
    end
    @hs_integration_options = [['Sincronizar todos los contactos', true], ['Sincronizar solo contactos seleccionados', false]]
    @hubspot_mapped_fields = current_retailer.customer_hubspot_fields.where.not(customer_field: 'tags').includes(:hubspot_field)
    @customer_fields = Customer.public_fields + current_retailer.customer_related_fields.pluck(:name)
  end

  def create
    customer_hubspot_field = CustomerHubspotField.new(mapped_fields_params)
    notice = if customer_hubspot_field.save
               'Nuevo campo mapeado.'
             else
               'Error al mapear campo.'
             end
    redirect_to retailers_hubspot_index_path(current_retailer), notice: notice
  end

  def update
    customer_hubspot_field = CustomerHubspotField.find(params[:id])
    notice = if customer_hubspot_field.update(mapped_fields_params)
               'Actualizado.'
             else
               'Error al mapear campo.'
             end
    redirect_to retailers_hubspot_index_path(current_retailer), notice: notice
  end

  def update_matching
    current_retailer.update(
      hubspot_match: params[:hubspot_match],
      all_customers_hs_integrated: params[:all_customers_hs_integrated]
    )
    redirect_to retailers_hubspot_index_path(current_retailer), notice: 'Cambiadas las opciones de emparejamiento'
  end

  def destroy
    customer_field = current_retailer.customer_hubspot_fields.find_by_id(params[:id])
    if customer_field.nil?
      redirect_to retailers_hubspot_index_path(current_retailer), notice: 'No existe el campo mapeado.'
      return
    end

    notice = customer_field.destroy ? 'Campo mapeado eliminado.' : 'Error al eliminar campo mapeado.'
    redirect_to retailers_hubspot_index_path(current_retailer), notice: notice
  end

  private

    def mapped_fields_params
      params.require(:mapped_fields)
            .permit(
              :hubspot_field_id,
              :customer_field
            ).merge(retailer_id: current_retailer.id)
    end
end
