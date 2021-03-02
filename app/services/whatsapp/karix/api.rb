require 'mime/types'

module Whatsapp
  module Karix
    class Api
      def prepare_send_whatsapp_message_url
        'https://api.karix.io/message/'
      end

      def prepare_whatsapp_message_text(retailer, customer, params)
        {
          channel: 'whatsapp',
          source: retailer.karix_whatsapp_phone,
          destination: [
            params[:phone_number] || customer.phone
          ],
          content: {
            text: params[:message]
          },
          events_url: "#{ENV['KARIX_WEBHOOK']}?account_id=#{retailer.id}"
        }.to_json
      end

      def prepare_whatsapp_message_file(retailer, customer, params, index = nil)
        if params[:file_data].present?
          file = index ? params[:file_data][index] : params[:file_data]
          resource_type = get_resource_type(file)
          response = upload_file_to_cloudinary(file, resource_type)
          filename = response['original_filename'] if resource_type == 'document'

          url = response['secure_url'] || response['url']
          caption = params[:caption] || filename
        elsif params[:url].present?
          url = params[:url]
          caption = params[:caption] || ''
        end

        {
          channel: 'whatsapp',
          source: retailer.karix_whatsapp_phone,
          destination: [
            customer.phone
          ],
          content: {
            media: {
              url: url,
              caption: caption
            }
          },
          events_url: "#{ENV['KARIX_WEBHOOK']}?account_id=#{retailer.id}"
        }.to_json
      end

      def prepare_whatsapp_message_location(retailer, customer, params)
        {
          channel: 'whatsapp',
          source: retailer.karix_whatsapp_phone,
          destination: [
            customer.phone
          ],
          content: {
            location: {
              longitude: params[:longitude].round(7).to_s,
              latitude: params[:latitude].round(7).to_s,
              label: ''
            }
          },
          events_url: "#{ENV['KARIX_WEBHOOK']}?account_id=#{retailer.id}"
        }.to_json
      end

      def upload_file_to_cloudinary(file, resource_type)
        timestamp = Time.now.to_i

        params_to_sign = {
          timestamp: timestamp
        }

        public_id = File.basename(file.original_filename) if resource_type == 'document'
        public_id = public_id.strip.gsub(/[?&#%<>\\]/, '').gsub(/^\/|\/$/, '') if public_id.present?

        Cloudinary::Uploader.upload(
          file,
          public_id: public_id,
          api_key: ENV['CLOUDINARY_API_KEY'],
          timestamp: timestamp,
          signature: Cloudinary::Utils.api_sign_request(params_to_sign, ENV['CLOUDINARY_API_SECRET']),
          resource_type: cloudinary_resource_type(resource_type)
        )
      end

      def get_resource_type(file)
        content_type = MIME::Types.type_for(file.tempfile.path).first.content_type
        return unless content_type.present?
        return 'image' if content_type.include?('image')
        return 'document' if ['application/pdf', 'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].include?(content_type)
      end

      # Prepara el cuerpo del mensaje que se enviara
      def prepare_chat_bot_message(*args)
        chat_bot_option, customer, get_out, error_exit, failed_attempt, concat_answer_type = args
        return unless chat_bot_option.present?

        chat_bot = chat_bot_option.chat_bot
        # Si es un intento fallido y el bot tiene configurado un mensaje personalizado para estos
        # casos, se toma dicho mensaje.
        return chat_bot.on_failed_attempt_message if chat_bot.on_failed_attempt == 'send_attempt_message' &&
                                                     failed_attempt

        # Se carga el contenido de la opcion
        option_body(chat_bot_option, customer, get_out, error_exit, concat_answer_type)
      end

      def cloudinary_resource_type(resource_type)
        return 'image' if resource_type == 'image'
        return 'video' if ['audio', 'voice', 'video'].include?(resource_type)

        'raw'
      end

      # Construye la lista de opciones a seleccionar tomando en cuenta la sublista de la opcion.
      def prepare_option_sub_list(chat_bot_option, message)
        message += get_option_answer(chat_bot_option, true)
        items_size = chat_bot_option.option_sub_lists.size - 1

        chat_bot_option.option_sub_lists.order(:position).each_with_index do |item, index|
          message += (item.position.to_s + '. ' + item.value_to_show)
          message += "\n" if index != items_size
        end

        message
      end

      # Construye la lista de opciones a seleccionar tomando en cuenta la respuesta del endpoint.
      def prepare_dynamic_sub_list(customer)
        data = customer.endpoint_response

        message = data.message + "\n\n"
        items_size = data.options.size - 1

        data.options.each_with_index do |item, index|
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
        if chat_bot_option.has_sub_list? && chat_bot_option.has_additional_answers_filled? == false
          prepare_option_sub_list(chat_bot_option, message)
        elsif chat_bot_option.is_auto_generated?
          prepare_dynamic_sub_list(customer)
        else
          message + get_option_answer(chat_bot_option, false)
        end
      end

      # Setea la respuesta del endpoint en caso de que la opcion tenga dicha accion.
      # Si el parametro concat_answer_type es 'success', toma la respuesta de exito.
      # Si el parametro concat_answer_type es 'failed', toma la respuesta de fallo.
      def set_text_from_response(chat_bot_option, customer, concat_answer_type)
        message = if concat_answer_type == 'success'
                    customer.endpoint_response.message
                  elsif concat_answer_type == 'failed'
                    customer.endpoint_failed_response.message
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
      def option_body(chat_bot_option, customer, get_out, error_exit, concat_answer_type)
        # inicializa el mensaje a enviar
        message = set_text_from_response(chat_bot_option, customer, concat_answer_type)

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
    end
  end
end
