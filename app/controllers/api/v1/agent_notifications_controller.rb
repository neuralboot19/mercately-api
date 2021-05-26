class Api::V1::AgentNotificationsController < Api::ApiController
  include CurrentRetailer

  def notifications_list
    @notifications = current_retailer_user.agent_notifications.order(created_at: :desc).page(params[:page]) if current_retailer_user
    render json: { notifications: AgentNotificationSerializer.new(@notifications), total: @notifications.total_pages }
  end

  def mark_as_read
    AgentNotification.find(permit_params[:id]).read!
    render status: :ok, json: { head: :ok }
  rescue StandardError
    render status: 400, json: { error: 'Error al marcar la notificación como leída, intente nuevamente' }
  end

  # Marks all customer-related notifications as read
  # This method is also used to message's first page eager loading. When user clicks on a specific sidebar chat, a
  # broadcast event is fired, so counters & unread messages notification could be refreshed
  def mark_by_customer_as_read
    customer = Customer.find(permit_params[:customer_id])
    customer.update_attribute(:unread_whatsapp_chat, false)
    agents_to_notify = customer.agent.present? ? [customer.agent] : current_retailer.retailer_users.all_customers.to_a
    if current_retailer.karix_integrated?
      customer.karix_whatsapp_messages
        .where(direction: 'inbound')
        .where.not(status: %w[read failed])
        .update_all(status: 'read')
      KarixNotificationHelper.broadcast_data(current_retailer, agents_to_notify, nil,
                                             customer.agent_customer, customer)
    elsif current_retailer.gupshup_integrated?
      customer.gupshup_whatsapp_messages
        .where(direction: 'inbound')
        .where.not(status: %w[read error])
        .update_all(status: 'read')
      messages_first_page = customer
        .gupshup_whatsapp_messages
        .allowed_messages
        .order(created_at: :desc)
        .page(1)
      Whatsapp::Gupshup::V1::Helpers::Messages.new(messages_first_page)
        .notify_messages!(current_retailer, agents_to_notify)
    end
    notification_ids = AgentNotification.mark_by_customer_as_read!(permit_params[:customer_id], permit_params[:notification_type])
    render status: :ok, json: { notification_ids: notification_ids }
  rescue StandardError
    render status: 400, json: { error: 'Error al marcar las notificaciones como leídas, intente nuevamente' }
  end

  private

    def permit_params
      params.require(:agent_notification).permit(
        :id,
        :customer_id,
        :notification_type
      )
    end
end
