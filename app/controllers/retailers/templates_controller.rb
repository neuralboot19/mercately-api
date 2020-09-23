class Retailers::TemplatesController < RetailersController
  before_action :check_ownership, only: [:show, :edit, :update, :destroy]
  before_action :set_template, only: [:show, :edit, :update, :destroy]
  before_action :check_permissions, only: [:show, :edit, :update, :destroy]

  # GET /templates
  def index
    @templates = current_retailer.templates.owned(current_retailer_user.id).page(params[:page])
  end

  # GET /templates/1
  def show
  end

  # GET /templates/new
  def new
    @template = Template.new
  end

  # GET /templates/1/edit
  def edit
  end

  # POST /templates
  def create
    @template = current_retailer.templates.new(template_params)
    @template.retailer_user = current_retailer_user

    if @template.save
      redirect_to retailers_template_path(current_retailer, @template), notice:
        'Respuesta creada con éxito.'
    else
      render :new
    end
  end

  # PATCH/PUT /templates/1
  def update
    if @template.update(template_params)
      redirect_to retailers_template_path(current_retailer, @template), notice:
        'Respuesta actualizada con éxito.'
    else
      render :edit
    end
  end

  # DELETE /templates/1
  def destroy
    @template.destroy
    redirect_to retailers_templates_url, notice: 'Respuesta eliminada con éxito.'
  end

  # Filtra las plantillas para preguntas por titulo o respuesta
  def templates_for_questions
    templates = current_retailer.templates.for_questions.owned_and_filtered(params[:search], current_retailer_user.id)

    render json: templates
  end

  # Filtra las plantillas para chats por titulo o respuesta
  def templates_for_chats
    templates = current_retailer.templates.for_chats.owned_and_filtered(params[:search], current_retailer_user.id)

    render json: templates
  end

  private

    def check_ownership
      template = Template.find_by(web_id: params[:id])
      redirect_to retailers_dashboard_path(@retailer) unless template && @retailer.templates.exists?(template.id)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_template
      @template = Template.find_by(web_id: params[:id])
    end

    def check_permissions
      return unless @template.retailer_user_id && current_retailer_user.agent?
      return if @template.retailer_user_id == current_retailer_user.id

      redirect_to retailers_templates_path(current_retailer), notice: 'No tienes permisos sobre la respuesta'
    end

    # Only allow a trusted parameter "white list" through.
    def template_params
      params.require(:template).permit(
        :title,
        :answer,
        :enable_for_questions,
        :enable_for_chats,
        :enable_for_messenger,
        :enable_for_whatsapp,
        :image,
        :global
      )
    end
end
