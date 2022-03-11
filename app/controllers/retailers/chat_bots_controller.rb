class Retailers::ChatBotsController < RetailersController
  include ChatBotsControllerConcern
  before_action :check_bots_access, except: :index
  before_action :check_ownership, except: [:index, :new, :create]
  before_action :set_chat_bot, except: [:index, :new, :create]
  before_action :resize_images, only: [:create, :update]
  after_action :check_options_attachment, only: [:update]

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
    if option.present?
      options = option.subtree.active.order(:position).arrange_serializable do |parent, children|
        TreeOptionSerializer.new(parent, children: children)
      end
    end

    render status: 200, json: { options: options }
  end

  def path_option
    option = @chat_bot.chat_bot_options.find(params[:option_id])
    serialized = ChatBotOptionSerializer.new(option.path.with_attached_file)

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
      params[:chat_bot][:reactivate_after] = nil unless params[:chat_bot][:check_reactivate_after].present?

      params.require(:chat_bot).permit(
        :name,
        :trigger,
        :failed_attempts,
        :goodbye_message,
        :any_interaction,
        :enabled,
        :error_message,
        :reactivate_after,
        :on_failed_attempt,
        :on_failed_attempt_message,
        :platform,
        chat_bot_options_attributes: [
          :id,
          :text,
          :answer,
          :parent_id,
          :file,
          :file_deleted,
          :option_type,
          :skip_option,
          :go_past_option,
          :go_start_option,
          chat_bot_actions_attributes: [
            :id,
            :retailer_user_id,
            :action_type,
            :_destroy,
            :target_field,
            :webhook,
            :action_event,
            :username,
            :password,
            :payload_type,
            :classification,
            :exit_message,
            :jump_option_id,
            :team_assignment_id,
            tag_ids: [],
            headers_attributes: [
              :key,
              :value,
              :_destroy
            ],
            data_attributes: [
              :key,
              :value,
              :_destroy
            ]
          ],
          option_sub_lists_attributes: [
            :id,
            :value_to_save,
            :value_to_show,
            :list_type,
            :_destroy
          ],
          additional_bot_answers_attributes: [
            :id,
            :text,
            :file,
            :file_deleted,
            :_destroy
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

    def check_options_attachment
      chat_bot_params[:chat_bot_options_attributes].each do |cbo_param|
        next unless cbo_param[1][:id].present?

        cbo = @chat_bot.chat_bot_options.find(cbo_param[1][:id])
        cbo.file.purge if cbo.file.attached? && cbo_param[1][:file_deleted] == 'true' && !cbo_param[1][:file]

        cbo_param[1][:additional_bot_answers_attributes]&.each do |aba_param|
          next unless aba_param[1][:id].present?

          aba = cbo.additional_bot_answers.find_by_id(aba_param[1][:id])
          next unless aba.present?

          aba.file.purge if aba.file.attached? && aba_param[1][:file_deleted] == 'true' && !aba_param[1][:file]
        end
      end
    end
end
