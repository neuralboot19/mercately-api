class Retailers::GsTemplatesController < RetailersController
  # GET retailers/:slug/gs_templates
  def index
    params[:q]&.delete_if { |_k, v| v == 'none' }
    @filter = current_retailer.gs_templates.ransack(params[:q])
    @gs_templates = @filter.result.page(params[:page])
  end

  # GET retailers/:slug/gs_templates/new
  def new
    @gs_template = current_retailer.gs_templates.new
  end

  # POST retailers/:slug/gs_templates
  def create
    @gs_template = current_retailer.gs_templates.new(gs_template_params)

    if @gs_template.save
      redirect_to retailers_gs_templates_path(current_retailer, q: { 's': 'created_at desc' }), notice:
        'Plantilla creada con éxito.'
    else
      render :new
    end
  end

  private

    def gs_template_params
      params.require(:gs_template).permit(:label, :language, :category, :text, :example)
    end
end
