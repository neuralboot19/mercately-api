module Retailers::Api::V1
  class KarixWhatsappController < Retailers::Api::V1::ApiController
    before_action :validate_balance, only: [:create, :create_by_id]

    KARIX_PERMITED_PARAMS = %w[
      channel
      content
      direction
      status
      destination
      country
      created_time
      error
    ].freeze

    def create
      params_present = params[:phone_number].present? && params[:message].present? && params[:template].present?
      set_response(500, 'Error: Missing phone number and/or message and/or template') && return unless params_present

      integration = current_retailer.karix_integrated? ? 'karix' : 'gupshup'
      self.send("send_#{integration}_notification", params)
    end

    def create_by_id
      set_response(400, 'Error: Missing phone number and/or gupshup_template_id') and
        return unless template_params_complete?

      template = find_template
      set_response(404, 'Error: Template not found. Please check the ID sent.') and
        return unless template.present?

      ok_params, params_required, params_sent = template.check_params_match(params)
      set_response(400, "Error: Parameters mismatch. Required #{params_required}, but #{params_sent} sent.") and
        return unless ok_params

      params[:template] = true
      params[:message] = template.template_text(params)

      integration = current_retailer.karix_integrated? ? 'karix' : 'gupshup'
      self.send("send_#{integration}_notification", params)
    end

    private

      def send_karix_notification(params)
        karix_helper = KarixNotificationHelper
        response = karix_helper.ws_message_service.send_message(current_retailer, nil, params, 'text')

        is_error = response['error'].present? || response['objects'][0]['status'] == 'failed'
        error = response['error'] || response['objects'][0]['error']
        set_response(500, 'Error', error.to_json) && return if is_error

        message = current_retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
        message = karix_helper.ws_message_service.assign_message(message, current_retailer, response['objects'][0])
        message.save

        agent = message.customer.agent
        agents = agent.present? ? [agent] : current_retailer.retailer_users.to_a
        karix_helper.broadcast_data(current_retailer, agents, message)
        set_response(200, 'Ok', format_response(response['objects'][0]))
      end

      def send_gupshup_notification(params)
        customer = find_customer(params[:phone_number].strip)
        set_response(500, 'Error', { message: 'No fue posible verificar el número de destino' }.to_json) &&
          return unless customer&.whatsapp_opt_in

        gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(current_retailer, customer)
        type = true?(params[:template]) ? 'template' : 'text'

        response = gws.send_message(type: type, params: params)

        if response[:code] == '200'
          data = {
            channel: 'whatsapp',
            content: {
              text: params[:message]
            },
            direction: 'outbound',
            status: response[:body]['status'],
            destination: customer&.phone,
            country: customer&.country_id,
            created_time: Time.now,
            error: nil
          }

          set_response(200, 'Ok', data.to_json)
        else
          set_response(500, 'Error', { message: 'No fue posible entregar el mensaje al número de destino' }.to_json)
        end
      end

      def format_response(object)
        object.slice(*KARIX_PERMITED_PARAMS).to_json
      end

      def validate_balance
        is_template = ActiveModel::Type::Boolean.new.cast(params[:template])

        return if current_retailer.unlimited_account && is_template == false
        return if current_retailer.positive_balance?

        render status: 401, json: { message: 'Usted no tiene suficiente saldo para enviar mensajes de Whatsapp, ' \
                                              'por favor, contáctese con su agente de ventas para recargar su saldo' }
        return
      end

      def true?(text)
        return true if text === 'true' || text === true
        false
      end

      def find_customer(phone_number)
        phone = phone_number[0] != '+' ? "+#{phone_number}" : phone_number
        customer = current_retailer.customers.find_or_initialize_by(phone: phone)
        if customer.new_record?
          customer.first_name = params[:first_name]
          customer.last_name = params[:last_name]
          customer.email = params[:email]
        end

        if customer.country_id.blank?
          parse_phone = Phonelib.parse(customer.phone)
          customer.country_id = parse_phone&.country
        end

        customer.send_for_opt_in = true
        customer.save

        customer
      end

      def template_params_complete?
        params[:phone_number].present? && params[:gupshup_template_id].present?
      end

      def find_template
        current_retailer.whatsapp_templates.find_by(gupshup_template_id: params[:gupshup_template_id].strip)
      end
  end
end
