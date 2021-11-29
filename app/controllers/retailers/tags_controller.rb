class Retailers::TagsController < RetailersController
  before_action :check_ownership, only: [:show, :edit, :update, :destroy]
  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  def index
    @tags = current_retailer.tags.order(updated_at: :desc).page(params[:page])
  end

  def show
  end

  def new
    @tag = Tag.new
  end

  def edit
  end

  def create
    @tag = current_retailer.tags.new(tag_params)

    if @tag.save
      redirect_to retailers_tag_path(current_retailer, @tag), notice:
        'Etiqueta creada con éxito.'
    else
      render :new
    end
  end

  def update
    if @tag.update(tag_params)
      redirect_to retailers_tag_path(current_retailer, @tag), notice:
        'Etiqueta actualizada con éxito.'
    else
      render :edit
    end
  end

  def destroy
    if @tag.destroy
      redirect_to retailers_tags_path(current_retailer), notice:
        'Etiqueta eliminada con éxito.'
    else
      redirect_to retailers_tags_path(current_retailer), notice:
        'Error al eliminar etiqueta.'
    end
  end

  private

    def tag_params
      params.require(:tag).permit(:tag, :tag_color)
    end

    def check_ownership
      tag = Tag.find_by(web_id: params[:id])
      redirect_to retailers_dashboard_path(current_retailer) unless tag && current_retailer.tags.exists?(tag.id)
    end

    def set_tag
      @tag = Tag.find_by(web_id: params[:id])
    end
end
