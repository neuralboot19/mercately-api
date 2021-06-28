# frozen_string_literal: true

class Api::V1::MlChatsController < Api::ApiController
  include CurrentRetailer

  before_action :set_order

  # GET /api/v1/orders/:id/ml_chats
  def index
    @filter = @order.messages
    unread_messages = @filter.where(date_read: nil, answer: nil)
    if unread_messages.exists?
      unread_messages.update_all(date_read: Time.now)
      update_counter
    end
    @ml_chats = @filter.order(created_at: :desc).page(params[:page])
    total_pages = @ml_chats&.total_pages
    render status: 200, json: {
      ml_chats: @ml_chats.reverse,
      total_ml_chats: total_pages
    }
  end

  # POST /api/v1/orders/:id/ml_chats
  def create
    @message = @order.messages.new(ml_chat_params)
    @message.customer_id = @order.customer_id
    @message.sender_id = current_retailer_user.id
    @message.meli_question_type = Question.meli_question_types[:from_order]

    msg = MercadoLibre::Messages.new(current_retailer).answer_message(@message)
    @message.meli_id = msg&.[]('id')
    if @message.meli_id && @message.save
      render status: 200, json: { ml_chat: @message }
    else
      error_msg = if @message.meli_id.blank?
                    Raven.capture_message('MercadoLibre service is down')
                    'MercadoLibre service is down'
                  else
                    @message.errors
                  end
      render status: 400, json: { ml_chat: @message, errors: error_msg }
    end
  end

  private

    def ml_chat_params
      params.require(:ml_chat).permit(
        :answer
      )
    end

    def set_order
      # Editar también en el index de api/v1/orders#index
      @order = Order.includes(:customer).joins(:messages)
        .where.not(questions: { id: nil })
        .where(customers: { retailer_id: current_retailer.id })
        .find_by(web_id: params[:id]) || not_found
    end

    def update_counter
      ml_helper = MercadoLibreNotificationHelper
      ml_helper.subtract_messages_counter(retailer: current_retailer, order: @order)
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end
end
