# frozen_string_literal: true

class Api::V1::OrdersController < Api::ApiController
  include CurrentRetailer

  before_action :set_order, except: :index

  # GET /api/v1/orders/
  def index
    params[:q]&.delete_if { |_k, v| v == 'none' }
    # Editar también en el index de api/v1/ml_chats#set_order
    @filter = Order.joins(:customer, :messages)
      .select('orders.*, MAX(questions.created_at) as recent_message_date')
      .where.not(questions: { id: nil })
      .where(customers: { retailer_id: current_retailer.id })
    @orders = @filter.group('orders.id').order('recent_message_date DESC').page(params[:page])
    @orders = @orders&.offset(false)&.offset(params[:offset])
    total_pages = @orders&.total_pages
    render status: 200, json: {
      # Editar tambien en MercadoLibreNotificationHelper
      orders: @orders.as_json(
        include: [:customer, :products],
        methods: [:unread_message, :order_img, :last_message, :unread_messages_count]
      ),
      total_orders: total_pages
    }
  end

  def mark_messages_as_read
    @order.messages.where(date_read: nil, answer: nil).update_all(date_read: Time.now)
    MercadoLibreNotificationHelper.mark_chat_as_read(retailer: current_retailer, order_web_id: @order.web_id)
    render status: 200, json: { message: 'success' }
  end

  private

    def set_order
      # Editar también en el index de api/v1/orders#index
      @order = Order.includes(:customer).joins(:messages)
        .where.not(questions: { id: nil })
        .where(customers: { retailer_id: current_retailer.id })
        .find_by(web_id: params[:id]) || not_found
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end
end
