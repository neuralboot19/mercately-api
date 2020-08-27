class Retailers::ChatBotsController < RetailersController
  before_action :check_bots_access, except: :index
  before_action :check_ownership, except: [:index, :new, :create]
  before_action :set_chat_bot, except: [:index, :new, :create]

  def index
    @chat_bots = current_retailer.chat_bots.page(params[:page])
  end

  def new
    @chat_bot = ChatBot.new
  end

  def create
    @chat_bot = current_retailer.chat_bots.new(chat_bot_params)

    if @chat_bot.save
      redirect_to retailers_chat_bots_path(current_retailer), notice:
        'ChatBot creado con éxito.'
    else
      render :new
    end
  end

  def update
    if @chat_bot.update(chat_bot_params)
      if params[:return_to] == 'list'
        redirect_to retailers_chat_bot_list_chat_bot_options_path(current_retailer, @chat_bot), notice:
          'ChatBot actualizado con éxito.'
      else
        redirect_to edit_retailers_chat_bot_path(current_retailer, @chat_bot), notice:
          'ChatBot actualizado con éxito.'
      end
    else
      render :edit
    end
  end

  def new_chat_bot_option
    @parent = @chat_bot.chat_bot_options.find_by_id(params[:parent_id])
  end

  def edit_chat_bot_option
    @chat_bot_option = @chat_bot.chat_bot_options.find_by_id(params[:option_id])
    @parent = @chat_bot_option.parent.presence || @chat_bot_option
  end

  def tree_options
    option = @chat_bot.chat_bot_options.first
    options = option.subtree.active.order(:position).arrange_serializable if option.present?

    render status: 200, json: { options: options }
  end

  def path_option
    option = @chat_bot.chat_bot_options.find(params[:option_id])
    serialized = ChatBotOptionSerializer.new(option.path)

    render status: 200, json: { option: serialized }
  end

  def delete_chat_bot_option
    option = @chat_bot.chat_bot_options.find_by_id(params[:option_id])
    response_to_delete(500, 'No puedes eliminar esta opción.') and return if option&.is_root?

    if option&.update(option_deleted: true)
      response_to_delete(200, 'Opción eliminada con éxito.')
    else
      response_to_delete(500, 'Error al eliminar la opción.')
    end
  end

  private

    def chat_bot_params
      params.require(:chat_bot).permit(
        :name,
        :trigger,
        :failed_attempts,
        :goodbye_message,
        :any_interaction,
        :enabled,
        :error_message,
        :repeat_menu_on_failure,
        chat_bot_options_attributes: [
          :id,
          :text,
          :answer,
          :parent_id,
          chat_bot_actions_attributes: [
            :id,
            :retailer_user_id,
            :action_type,
            :_destroy,
            tag_ids: []
          ]
        ]
      )
    end

    def check_ownership
      chat_bot = current_retailer.chat_bots.find_by_web_id(params[:id] || params[:chat_bot_id])
      redirect_to retailers_dashboard_path(current_retailer) unless chat_bot
    end

    def set_chat_bot
      @chat_bot = ChatBot.find_by_web_id(params[:id] || params[:chat_bot_id])
    end

    def check_bots_access
      redirect_to retailers_dashboard_path(current_retailer) unless current_retailer.allow_bots
    end

    def response_to_delete(status, message)
      respond_to do |format|
        format.html {
          redirect_to retailers_chat_bot_list_chat_bot_options_path(current_retailer, @chat_bot), notice: message
        }
        format.json {
          render json: { status: status, message: message }
        }
      end
    end
end
