class Api::V1::GsTemplatesController < Api::ApiController
  include CurrentRetailer

  # POST /api/v1/gs_templates
  def create
    @gs_template = current_retailer.gs_templates.new(gs_template_params)

    if @gs_template.save
      render status: 200, json: { message: 'Plantilla creada con éxito' }
    else
      render status: 400, json: { message: 'Error al crear plantilla', errors: @gs_template.errors }
    end
  end

  private

    def gs_template_params
      params.require(:gs_template).permit(:label, :language, :category, :text, :example, :key, :file)
    end
end