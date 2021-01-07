class Api::V1::AgentNotificationsController < Api::ApiController
  include CurrentRetailer

  def mark_as_read
    AgentNotification.find(permit_params[:id]).read!
    render status: :ok, json: { head: :ok }
  rescue StandardError
    render status: 400, json: { error: 'Error al marcar la notificación como leída, intente nuevamente' }
  end

  def mark_by_customer_as_read
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
