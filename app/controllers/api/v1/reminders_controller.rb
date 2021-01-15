class Api::V1::RemindersController < Api::ApiController
  include CurrentRetailer
  before_action :authenticate_retailer_user!

  def create
    params[:reminder][:content_params] = JSON.parse(params[:reminder][:content_params])
    @reminder = current_retailer.reminders.new(reminder_params)
    @reminder.retailer_user_id = current_retailer_user.id

    render json: { message: 'Recordatorio creado con éxito' } if @reminder.save
  end

  private

    def reminder_params
      params.require(:reminder).permit(
        :customer_id,
        :whatsapp_template_id,
        :send_at,
        :timezone,
        :status,
        :file,
        content_params: []
      )
    end
end
