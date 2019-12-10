class Retailers::TemplatesController < RetailersController
  before_action :set_template, only: [:show, :edit, :update, :destroy]

  # GET /templates
  def index
    @templates = current_retailer.templates.page(params[:page])
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

    if @template.save
      redirect_to retailers_template_path(current_retailer.slug, current_retailer.web_id, @template), notice:
        'Plantilla creada con éxito.'
    else
      render :new
    end
  end

  # PATCH/PUT /templates/1
  def update
    if @template.update(template_params)
      redirect_to retailers_template_path(current_retailer.slug, current_retailer.web_id, @template), notice:
        'Plantilla actualizada con éxito.'
    else
      render :edit
    end
  end

  # DELETE /templates/1
  def destroy
    @template.destroy
    redirect_to retailers_templates_url, notice: 'Pantilla eliminada con éxito.'
  end

  # Filtra las plantillas para preguntas por titulo o respuesta
  def templates_for_questions
    templates = current_retailer.templates.for_questions.where('title ILIKE ?' \
      ' OR answer ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%")

    render json: templates
  end

  # Filtra las plantillas para chats por titulo o respuesta
  def templates_for_chats
    templates = current_retailer.templates.for_chats.where('title ILIKE ?' \
      ' OR answer ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%")

    render json: templates
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_template
      @template = Template.find_by(web_id: params[:web_id] + params[:id])
      redirect_to retailers_dashboard_path(current_retailer.slug, current_retailer.web_id) unless @template
    end

    # Only allow a trusted parameter "white list" through.
    def template_params
      params.require(:template).permit(
        :title,
        :answer,
        :enable_for_questions,
        :enable_for_chats
      )
    end
end
