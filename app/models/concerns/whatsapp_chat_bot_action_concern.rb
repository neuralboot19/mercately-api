module WhatsappChatBotActionConcern
  extend ActiveSupport::Concern

  included do
    after_commit :chat_bot_execution, on: :create
  end

  def active_chat_bots
    retailer.chat_bots.whatsapp.enabled_ones
  end

  def before_last_message
    customer.before_last_whatsapp_message
  end

  # Se encarga de llamar al api para que estructure el mensaje a enviar.
  # chat_bot_option = opcion a enviar.
  # get_out = Se salio del chatbot.
  # error_exit = Se salio del chatbot por intentos fallidos.
  # failed_attempt = Es un intento fallido.
  # concat_answer_type = Dice si el mensaje viene de una respuesta exitosa o no del consumo de
  # un endpoint. Valores posibles: 'success', 'failed'
  def send_answer(chat_bot_option, concat_answer_type = nil, get_out = false, error_exit = false,
    failed_attempt = false, from_option = nil)
    return unless chat_bot_option.present?

    params = {
      message: api.prepare_chat_bot_message(chat_bot_option, customer, get_out, error_exit, failed_attempt,
        concat_answer_type, from_option),
      type: 'text'
    }

    # Se revisa el texto a enviar, por si tiene variables, sustituirlas por el valor real
    params[:message] = chat_bot_service.replace_message_variables(params[:message])

    # En caso de que sea un intento fallido y hayan respuestas adicionales, las opciones a
    # seleccionar se insertan en la respuesta original, ya que las adicionales no se envian
    # en intentos fallidos.
    if failed_attempt && chat_bot_option.chat_bot.on_failed_attempt == 'resend_options' &&
      chat_bot_option.has_additional_answers_filled?
      params[:message] = chat_bot_service.append_options_to_message(chat_bot_option, params[:message])
    end

    # Recopila la informacion del adjunto para enviar
    if chat_bot_option.file.attached? && !failed_attempt && !error_exit
      params = attachment_data(chat_bot_option, nil, params)
    end

    send_bot_message(params)
  end

  # Se encarga de enviar las respuestas adicionales que posee la opcion del bot.
  def send_additional_answers(option)
    sleep 5 if option&.file&.attached?
    return unless option&.has_additional_answers_filled?

    # Se carga con with_attached_file para evitar un N+1
    additional_answers = option.additional_bot_answers.with_attached_file.order(id: :asc)
      .map { |m| m if m.text.present? || m.file.attached? }

    size = additional_answers.size - 1
    additional_answers.each_with_index do |aba, index|
      has_file = aba.file.attached?
      last_one = index == size
      params = {
        message: chat_bot_service.replace_message_variables(aba.text),
        type: 'text'
      }

      # Recopila la informacion del adjunto para enviar
      params = attachment_data(option, aba, params, last_one) if has_file
      # De no ser un archivo, mandamos a agregar la lista de opciones al mensaje.
      # Solo si ya es la ultima respuesta adicional.
      params[:message] = chat_bot_service.append_options_to_message(option, params[:message]) if last_one && !has_file

      send_bot_message(params)
      sleep 5 if has_file
    end
  end

  private

    # Se ve de donde viene el mensaje, Karix o GS
    # El mensaje debe ser inbound de tipo texto para que pueda ejecutar el metodo.
    def chat_bot_execution
      case self.class.name
      when 'KarixWhatsappMessage'
        return unless direction == 'inbound' && content_type == 'text'

        @text = content_text
      when 'GupshupWhatsappMessage'
        return unless direction == 'inbound' && (type == 'text' || type == 'quick_reply')

        @text = message_payload['payload'].try(:[], 'payload').try(:[], 'text') || message_payload['text']
      end

      chat_bot_service.manage_chat_bot
    end

    # Toma el adjunto de la opcion o de la respuesta adicional y construye los parametros
    # necesarios para su correcto envio.
    def attachment_data(option, object, params, last = false)
      object ||= option
      # For pdf attachments, send caption in another message
      aux_url = object.file_url
      is_pdf = object.file.content_type == 'application/pdf'

      if is_pdf
        aux_url += '.pdf'

        params[:message] = chat_bot_service.append_options_to_message(option, params[:message]) if last

        send_bot_message(params)
      end
      params[:type] = 'file'
      params[:content_type] = object.file.content_type
      params[:url] = aux_url
      # Karix service sets PDF name based on caption param
      if retailer.karix_integrated? && is_pdf
        params[:caption] = object.file.blob.filename.to_s
      else
        params[:caption] = is_pdf ? params[:message] :
          (last ? chat_bot_service.append_options_to_message(option, params[:message]) : params[:message])
        params[:file_name] = object.file.blob.filename.to_s
      end

      params
    end

    # Se encarga de enviar los mensajes de GupShup.
    def send_gupshup_notification(params)
      return unless params[:message].present? || params[:url].present?

      gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(retailer, customer)
      gws.send_message(type: params[:type], params: params)
    end

    # Se encarga de mandar los mensajes de Karix.
    def send_karix_notification(params)
      karix_helper = KarixNotificationHelper
      response = karix_helper.ws_message_service.send_message(retailer, customer, params, params[:type])
      return if response['error'].present?

      message = retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
      message = karix_helper.ws_message_service.assign_message(message, retailer, response['objects'][0])
      message.save

      agents = customer.agent.present? ? [customer.agent] : retailer.retailer_users.all_customers.to_a
      karix_helper.broadcast_data(retailer, agents, message, customer.agent_customer)
    end

    def send_bot_message(params)
      if retailer.gupshup_integrated?
        send_gupshup_notification(params)
      else
        send_karix_notification(params)
      end
    end

    def chat_bot_service
      @chat_bot_service ||= ChatBots::ChatBotProcess.new(customer, retailer, self, @text)
    end

    def api
      ChatBots::Api.new
    end
end
