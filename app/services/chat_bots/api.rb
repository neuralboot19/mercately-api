module ChatBots
  class Api
    # Prepara el cuerpo del mensaje que se enviara
    def prepare_chat_bot_message(*args)
      chat_bot_option, customer, get_out, error_exit, failed_attempt, concat_answer_type, from_option = args
      return unless chat_bot_option.present?

      chat_bot = chat_bot_option.chat_bot
      # Si es un intento fallido y el bot tiene configurado un mensaje personalizado para estos
      # casos, se toma dicho mensaje.
      return chat_bot.on_failed_attempt_message if chat_bot.on_failed_attempt == 'send_attempt_message' &&
                                                   failed_attempt

      # Se carga el contenido de la opcion
      option_body(chat_bot_option, customer, get_out, error_exit, concat_answer_type, from_option)
    end

    # Construye la lista de opciones a seleccionar tomando en cuenta la sublista de la opcion.
    def prepare_option_sub_list(chat_bot_option, message)
      message += get_option_answer(chat_bot_option, true)
      items_list = chat_bot_option.items_list
      items_size = items_list.size - 1

      items_list.sort_by(&:position).each_with_index do |item, index|
        message += (item.position.to_s + '. ' + item.value_to_show)
        message += "\n" if index != items_size
      end

      message
    end

    # Construye la lista de opciones a seleccionar tomando en cuenta la respuesta del endpoint.
    def prepare_dynamic_sub_list(customer, chat_bot_option, message)
      data = @response.presence || customer.endpoint_response
      options = data.insert_return_options(chat_bot_option, data.options || [])

      message ||= ''
      items_size = options.size - 1

      options.each_with_index do |item, index|
        message += (item.position.to_s + '. ' + item.value)
        message += "\n" if index != items_size
      end

      message
    end

    # Se construye el mensaje a enviar en caso de que la opcion sea tipo Formulario.
    # Si tiene sublista, entonces se basa en ella.
    # Si es dinamica, toma las opciones de la respuesta del endpoint.
    # Sino es ninguna de las dos, toma solo la respuesta de la opcion.
    # Si es formulario, carga las opciones solo si no tiene respuestas adicionales la opcion.
    def build_message(chat_bot_option, customer, message)
      if (chat_bot_option.has_sub_list? || (!chat_bot_option.is_auto_generated? &&
        chat_bot_option.has_return_options?)) &&
        chat_bot_option.has_additional_answers_filled? == false
        prepare_option_sub_list(chat_bot_option, message)
      elsif chat_bot_option.is_auto_generated?
        prepare_dynamic_sub_list(customer, chat_bot_option, message)
      else
        message + get_option_answer(chat_bot_option, false)
      end
    end

    # Setea la respuesta del endpoint en caso de que la opcion tenga dicha accion.
    # Si el parametro concat_answer_type es 'success', toma la respuesta de exito.
    # Si el parametro concat_answer_type es 'failed', toma la respuesta de fallo.
    def set_text_from_response(chat_bot_option, customer, concat_answer_type, from_option, get_out)
      @response = search_response(chat_bot_option, customer, concat_answer_type, get_out)

      message = if @response.present?
                  @response.message
                elsif concat_answer_type == 'success'
                  customer.endpoint_response.message
                elsif concat_answer_type == 'failed'
                  customer.endpoint_failed_response.message
                end

      if from_option.present? && chat_bot_option.id != from_option.id && append_from_option(from_option)
        from_option_response = customer.customer_bot_responses
          .where(chat_bot_option_id: from_option.id, status: concat_answer_type).first&.response

        message = from_option_response.message + "\n\n" + message if from_option_response.present?
      end

      message.present? ? message + "\n\n" : ''
    end

    # Setea el mensaje de salida del bot, dependiendo si fue por intentos fallidos o no.
    def get_exit_message(chat_bot_option, get_out)
      if get_out
        # Si no fue por intentos fallidos, busca si en la accion de salida hay un mensaje configurado.
        # De haberlo lo toma, sino toma el mensaje de salida general del bot.
        action = chat_bot_option.chat_bot_actions.find_by_action_type(:get_out_bot)
        action&.exit_message.presence || chat_bot_option.chat_bot.goodbye_message
      else
        # Si es por intentos fallidos, toma el mensaje de salida por intentos fallidos del bot.
        chat_bot_option.chat_bot.error_message
      end
    end

    # Devuelve la respuesta de la opcion.
    def get_option_answer(chat_bot_option, concat)
      answer = chat_bot_option.answer.presence || ''
      answer += "\n\n" if concat && answer.present?

      answer
    end

    # Se encarga de formar el mensaje con toda la informacion necesaria.
    def option_body(chat_bot_option, customer, get_out, error_exit, concat_answer_type, from_option)
      # inicializa el mensaje a enviar
      message = set_text_from_response(chat_bot_option, customer, concat_answer_type, from_option, get_out)

      # Si no se esta saliendo del bot, ya sea por ejecucion o por intentos fallidos.
      if get_out == false && error_exit == false
        # Construye el mensaje si se trata de una opcion tipo Formulario y retorna
        return build_message(chat_bot_option, customer, message) if chat_bot_option.option_type == 'form'

        # Toma la respuesta de la opcion.
        message += get_option_answer(chat_bot_option, false)

        # Solo muestra las opciones hijas activas.
        # Carga las opciones solo si no tiene respuestas adicionales la opcion.
        children = chat_bot_option.children.active
        if chat_bot_option.jump_to_option? == false && children.present? &&
          chat_bot_option.has_additional_answers_filled? == false

          message += "\n\n"
          children_size = children.size - 1

          children.order(:position).each_with_index do |child, index|
            message += (child.position.to_s + '. ' + child.text)
            message += "\n" if index != children_size
          end
        end
      else
        # Si se esta saliendo del bot. Busca el mensaje de salida apropiado.
        message += get_exit_message(chat_bot_option, get_out)
      end

      message
    end

    # Busca la respuesta del endpoint guardada anteriormente para armar
    # el nuevo mensaje a enviar.
    def search_response(chat_bot_option, customer, concat_answer_type, get_out)
      if concat_answer_type == 'success'
        responses = customer.customer_bot_responses.order(chat_bot_option_id: :desc)

        if chat_bot_option.option_type == 'form' || (chat_bot_option.option_type == 'decision' &&
          !chat_bot_option.execute_endpoint?)
          return if chat_bot_option.ancestry.blank?

          response_on_success(responses, chat_bot_option, concat_answer_type, get_out)
        else
          responses.where('chat_bot_option_id = ? AND status = ?', chat_bot_option.id,
            CustomerBotResponse.statuses[concat_answer_type]).first&.response
        end
      elsif concat_answer_type == 'failed'
        customer.customer_bot_responses
          .where(chat_bot_option_id: chat_bot_option.id, status: concat_answer_type).first&.response
      elsif chat_bot_option.parent&.execute_endpoint?
        parent = chat_bot_option.parent
        return if chat_bot_option.ancestry.blank? || get_out || parent.option_type == 'decision'

        ancestor_ids = chat_bot_option.ancestry.split('/')
        customer.customer_bot_responses.order(chat_bot_option_id: :desc)
          .where('chat_bot_option_id IN (?) AND chat_bot_option_id < ?', ancestor_ids, chat_bot_option.id)
          .order(updated_at: :desc).first&.response
      end
    end

    # Busca y retorna la respuesta en success. Dependiendo si es un mensaje de salida o no.
    def response_on_success(responses, chat_bot_option, concat_answer_type, get_out)
      if get_out
        responses.where('chat_bot_option_id = ? AND status = ?', chat_bot_option.id,
          CustomerBotResponse.statuses[concat_answer_type]).first&.response
      else
        ancestor_ids = chat_bot_option.ancestry.split('/')
        responses.where('chat_bot_option_id IN (?) AND chat_bot_option_id < ? AND status = ?', ancestor_ids,
          chat_bot_option.id, CustomerBotResponse.statuses[concat_answer_type]).first&.response
      end
    end

    def append_from_option(option)
      option.option_type == 'form' || (option.answer.blank? && !option.file.attached? &&
        !option.has_additional_answers_filled?)
    end
  end
end
