class Api::V1::WhatsappTemplatesController < ApplicationController
  include CurrentRetailer
  before_action :authenticate_retailer_user!

  def index
    @templates = current_retailer.whatsapp_templates.active.page(params[:page])

    if @templates.present?
      render status: 200, json: { templates: @templates, total_pages: @templates.total_pages }
    else
      render status: 404, json: { message: 'No existen plantillas' }
    end
  end
end
