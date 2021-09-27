module MessengerChatBotActionConcern
  extend ActiveSupport::Concern

  included do
    after_commit :chat_bot_execution, on: :create
  end

  def active_chat_bots
    retailer.chat_bots.messenger.enabled_ones
  end

  def before_last_message
    customer.before_last_messenger_message
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
        concat_answer_type, from_option)
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

    send_bot_message(params)

    # Recopila la informacion del adjunto para enviar
    # Solo si la opción tiene un archivo y no es un reintento (para evitar hacer spam)
    return if !chat_bot_option.file.attached? || failed_attempt || error_exit

    params = attachment_data(chat_bot_option, nil)
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
      }

      # Mandamos a agregar la lista de opciones al mensaje.
      # Solo si ya es la ultima respuesta adicional.
      params[:message] = chat_bot_service.append_options_to_message(option, params[:message]) if last_one
      send_bot_message(params)
      next unless has_file

      # Recopila la informacion del adjunto para enviar
      params = attachment_data(option, aba)

      send_bot_message(params)
      sleep 5
    end
  end

  private

    # El mensaje debe ser inbound de tipo texto para que pueda ejecutar el metodo.
    def chat_bot_execution
      return if customer.instagram? # TODO: Reactivar bots para IG
      return unless sent_by_retailer == false && text.present?

      chat_bot_service.manage_chat_bot
    end

    # Toma el adjunto de la opcion o de la respuesta adicional y construye los parametros
    # necesarios para su correcto envio.
    def attachment_data(option, object)
      object ||= option
      params = {}

      aux_url = object.file_url
      if object.file.content_type == 'application/pdf'
        aux_url += '.pdf'
        # Esto se hace porque debemos enviar el PDF como objeto y no por URL,
        # ya que por URL no hay forma de colocarle un filename, y le llega
        # a los destinatarios con el key generado por Cloudinary.
        file = open(aux_url)
        params[:file_data] = file.path
        params[:file_content_type] = object.file.content_type
      else
        params[:file_url] = aux_url
      end

      params[:type] = object.file_type
      params[:filename] = object.file.filename.to_s

      params
    end

    def send_bot_message(params)
      return unless params[:message].present? || params[:file_url].present? || params[:file_data].present?

      FacebookMessage.create(
        customer: customer,
        id_client: customer.psid,
        facebook_retailer: facebook_retailer,
        text: params[:message].presence || nil,
        sent_from_mercately: true,
        sent_by_retailer: true,
        file_url: params[:file_url].presence || nil,
        file_data: params[:file_data].presence || nil,
        file_type: params[:type].presence || nil,
        filename: params[:filename].presence || nil,
        file_content_type: params[:file_content_type].presence || nil
      )
    end

    def chat_bot_service
      @chat_bot_service ||= ChatBots::ChatBotProcess.new(customer, retailer, self, text)
    end

    def api
      ChatBots::Api.new
    end
end
