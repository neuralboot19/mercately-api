class GupshupWhatsappController < ApplicationController
  protect_from_forgery with: :null_session, only: :save_message
  respond_to :json

  def save_message
    return render status: :ok, json: '' if save_message_params.try(:[], :payload).try(:[], :type) == 'sandbox-start'
    return render status: 500, json: '' unless save_message_params.try(:[], :payload).try(:[], :type).present? ||
      save_message_params[:type] == 'billing-event'

    event = save_message_params[:payload][:type]

    # Get the retailer by its gupshup_src_name, which is the gupshup app name
    retailer = Retailer.find_by_gupshup_src_name(save_message_params[:app])

    if !retailer
      # Returns a 404 if retailer not found
      message = { message: 'Gupshup Whatsapp app not found' }

      Rails.logger.error(message)
      SlackError.send_error(message)
      return render status: 404, json: message
    end

    if event == 'failed'
      Rails.logger.error(save_message_params[:payload])
      SlackError.send_error(save_message_params[:payload])
      event_handler = Whatsapp::Gupshup::V1::EventHandler.new(retailer)
      event_handler.process_error!(save_message_params)
      return render status: :ok, json: ''
    end

    event_handler = Whatsapp::Gupshup::V1::EventHandler.new(retailer)
    event_handler.process_event!(save_message_params)

    return render status: :ok, json: ''
  end

  private

    def save_message_params
      params.require(:gupshup_whatsapp)
            .permit(:app, :timestamp, :version, :type, payload: {})
    end
end
