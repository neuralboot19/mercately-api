class Retailers::RemindersController < RetailersController
  # GET retailers/:slug/reminders
  def index
    params[:q]&.delete_if { |_k, v| v == 'none' || v == 'Seleccionar' }
    @filter = if params[:q]&.[](:range).present?
                @start_date, @end_date = params[:q][:range].split(' - ')
                current_retailer.reminders
                  .includes(:customer)
                  .where(send_at: Date.strptime(@start_date, '%d/%m/%Y')..(Date.strptime((@end_date), '%d/%m/%Y') + 1.day))
                  .ransack(params[:q])
              else
                @start_date = Date.today
                @end_date = 1.day.from_now
                @start_date = @start_date.strftime('%d/%m/%Y')
                @end_date = @end_date.strftime('%d/%m/%Y')
                current_retailer.reminders
                  .includes(:customer)
                  .ransack(params[:q])
              end
    @reminders = @filter.result.page(params[:page]).order(created_at: :desc)
  end

  # PUT retailers/:slug/reminders/:id/cancel
  def cancel
    @reminder = Reminder.find_by(web_id: params[:id])
    @reminder.cancelled!
    redirect_back fallback_location: root_path
  end

  private

    def reminder_params
      params.require(:reminder).permit(
        :status
      )
    end
end
