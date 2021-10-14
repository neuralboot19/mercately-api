class Api::V1::WhatsappTemplatesController < Api::ApiController
  include CurrentRetailer

  def index
    @templates = current_retailer.whatsapp_templates.active

    if @templates.present?
      render status: 200, json: { templates: @templates }
    else
      render status: 404, json: { message: 'No existen plantillas' }
    end
  end
end
