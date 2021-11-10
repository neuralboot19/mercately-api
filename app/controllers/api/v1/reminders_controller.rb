class Api::V1::RemindersController < Api::ApiController
  include CurrentRetailer
  before_action :authenticate_retailer_user!

  def create
    params[:reminder][:content_params] = [] if params[:reminder][:content_params].blank?
    @reminder = current_retailer.reminders.new(reminder_params)
    @reminder.retailer_user_id = current_retailer_user.id

    if @reminder.save
      render json: {
        message: 'Recordatorio creado con éxito',
        reminders: serialize_reminders(@reminder.customer.reminders.order(created_at: :desc))
      }
    end
  end

  def cancel
    @reminder = Reminder.find_by(web_id: params[:id])
    @reminder.cancelled!
    @customer = @reminder.customer
    render status: 200, json: {
      customer: @customer.as_json(methods: [:emoji_flag, :tags, :assigned_agent]),
      hubspot_integrated: @customer.retailer.hubspot_integrated?,
      reminders: serialize_reminders(@customer.reminders.order(created_at: :desc)),
      tags: current_retailer.available_customer_tags(@customer.id)
    }
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

    def serialize_reminders(reminders)
      ActiveModelSerializers::SerializableResource.new(
        reminders,
        each_serializer: Api::V1::ReminderSerializer
      ).as_json
    end
end
