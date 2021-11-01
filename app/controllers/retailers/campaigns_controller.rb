# frozen_string_literal: true

class Retailers::CampaignsController < RetailersController
  before_action :set_campaign, only: %i[edit archive cancel download]
  before_action :check_contact_groups, only: %i[index new]
  before_action :whatsapp_integrated?, only: %i[index new]

  # GET retailers/:slug/campaigns
  def index
    params[:q]&.delete_if { |_k, v| v == 'none' }
    @filter = current_retailer.campaigns.ransack(params[:q])
    @campaigns = @filter.result.order(created_at: :desc).page(params[:page])
  end

  # GET retailers/:slug/campaigns/new
  def new
    @campaign = current_retailer.campaigns.new
    if params[:whatsapp_template_id]
      @whatsapp_template = current_retailer.whatsapp_templates.find(params[:whatsapp_template_id])
    end
  end

  # POST retailers/:slug/campaigns
  def create
    @campaign = current_retailer.campaigns.new(campaign_params)
    @campaign.timezone = params[:campaign_timezone]

    if @campaign.save
      redirect_to retailers_campaigns_path(current_retailer), notice: 'Campaña creada con éxito.'
    else
      flash[:notice] = @campaign.errors.full_messages.join(', ')
      render :new
    end
  end


  # PUT retailers/:slug/campaigns/:id/cancel
  def cancel
    if @campaign.processing?
      redirect_to(
        retailers_campaigns_path(current_retailer),
        notice: 'La campaña se está procesando, no puedes cancelarla'
      )
      return
    end

    @campaign.cancelled!

    redirect_to retailers_campaigns_path(current_retailer)
  end

  def download
    @messages = GupshupWhatsappMessage.where(campaign_id: @campaign.id, retailer_id: current_retailer.id).includes(:customer)

    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename=mercately-campaign-results.xlsx'
      }
    end
  end

  private

    def set_campaign
      @campaign = current_retailer.campaigns.find_by(web_id: params[:id]) || not_found
    end

    def check_contact_groups
      return if current_retailer.contact_groups.exists?

      redirect_to(retailers_contact_groups_path(current_retailer), notice: 'Debe crear un grupo de clientes primero') && return
    end

    def whatsapp_integrated?
      redirect_to(root_path, notice: 'No estás integrado con WhatsApp') && return unless current_retailer.whatsapp_integrated?
    end

    def campaign_params
      params.require(:campaign).permit(
        :name,
        :send_at,
        :contact_group_id,
        :whatsapp_template_id,
        :file,
        content_params: []
      )
    end
end
