class Api::V1::RemindersMobileController < Api::MobileController
  before_action :set_retailer

  def create
    params[:reminder][:content_params] = [] if params[:reminder][:content_params].blank?
    @reminder = @user.retailer.reminders.new(reminder_params)
    @reminder.retailer_user_id = @user.id

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
      tags: @user.retailer.available_customer_tags(@customer.id)
    }
  end

  private

    def set_retailer
      @user = RetailerUser.find_by_email(request.headers['email'] || create_params[:email])
      return record_not_found unless @user
      @user
    end

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
