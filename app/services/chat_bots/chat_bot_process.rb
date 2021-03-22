module ChatBots
  class ChatBotProcess
    include ChatBots::EndpointsConnection

    def initialize(customer, retailer, origin_instance, text)
      @customer = customer
      @retailer = retailer
      @origin_instance = origin_instance
      @text = text
    end

    # Se encarga de el manejo de comenzar un chatbot o continuar con las opciones
    # si es que ya hay un chatbot activo.
    def manage_chat_bot
      # Si ya ha pasado el tiempo de reactivacion del chatbot que tiene activo el chat, lo reseteamos.
      # Es decir que desactivamos el chatbot actual para poder activarlo de nuevo u otro.
      # Si el chatbot actual no tiene reactivacion, no pasa nada.
      @customer.deactivate_chat_bot! if chat_bot_out_of_time?

      text = @text.strip
      # Si el chat ya tiene un bot activo, operamos sobre la opcion actual del chat.
      # Sino, buscamos si hay un bot que haga match con lo que escribio la persona,
      # o si hay alguno que se active con cualquier interaccion.
      if @customer.active_bot
        # Opcion actual que tiene el chat
        @current_option = @customer.chat_bot_option
        # Nos dice si la opcion actual es de tipo Formulario
        @input_option = @current_option&.option_type == 'form'
        # Nos dice si la opcion actual ejecuta un endpoint
        @execute_endpoint = @current_option&.execute_endpoint?

        # Buscamos la opcion que haga match con lo que escribio la persona
        @selected = match_option(text)
        # Si la opcion no es encontrada y la opcion actual es de tipo Decision
        # retornamos y se envia el mensaje de fallo o se repiten las opciones.
        # Si es de tipo Formulario no retorna, ya que puede que no tenga opciones
        # hijas y termina la ejecucion en ella.
        return unless @selected || @input_option

        # Si la opcion actual es de tipo Formulario y tiene sublista, buscamos el match
        # en la sublista. Sino se consigue retornamos y se envia el mensaje de fallo
        # o se repiten las opciones.
        return if @current_option&.has_sub_list? && match_sub_list_items(text) == false
        # Si la opcion actual es autogenerada, buscamos el match
        # en la lista de opciones que vienen del endpoint. Sino se consigue retornamos y
        # se envia el mensaje de fallo o se repiten las opciones.
        return if @current_option&.is_auto_generated? && match_dynamic_list(text) == false

        # Si la opcion seleccionada no ejecuta un endpoint, se guarda la relacion de esta (@selected)
        # y el customer/chat en cuestion. En caso de que ejecute un endpoint, no se guarda, lo hace en
        # un paso siguiente, ya que debemos ver primero si la respuesta del endpoint es exitosa para
        # poder pasar a la siguiente opcion.
        save_customer_option unless @execute_endpoint
      else
        # Buscamos el bot que haga match con lo que escribio la persona o si hay alguno que se
        # active con cualquier interaccion.
        chat_bot = chat_bot_selection(text)
        # Sino se consigue retornamos y no pasa mas nada.
        return unless chat_bot.present?

        # Si es encontrado, tomamos la primera opcion del chatbot, que es la raiz.
        @selected = chat_bot.chat_bot_options.first
      end

      # Decidimos a cual opcion le vamos a ejecutar las acciones, tomando en cuenta si es de
      # tipo Decision o Formulario. Si es de tipo Formulario, ejecutamos las acciones de la
      # opcion actual. Si es de Decision, ejecutamos la de la opcion seleccionada (@selected)
      exec_option = option_to_execute
      # Actualizamos el customer/chat con la opcion seleccionada (@selected) para saber en que
      # paso del bot esta actualmente.
      update_customer_flow
      # Se ejecutan las acciones de la opcion que retorna el metodo option_to_execute
      execute_actions(exec_option)

      # Si la opcion seleccionada es de Formulario, y esta configurada para saltarse si tiene contenido,
      # y no se ha saltado a ninguna otra opcion en las acciones, entonces se chequea si tiene contenido
      # o no, para saber si mandarla o iniciar la recursividad para buscar la siguiente.
      if skip_this_action?(@selected)
        manage_skip_option(@selected)
        return
      end

      # Mandamos el mensaje con el contenido de la opcion seleccionada (@selected)
      unless @sent_in_action
        @origin_instance.send_answer(@selected, @concat_answer_type)
        @origin_instance.send_additional_answers(@selected)
      end
    end

    # Se encarga de ver si el maximo de intentos fallidos ya fueron alcanzados. En ese caso, envia un
    # mensaje avisando eso y deshabilita el bot. Sino, actualiza el customer y le incrementa los
    # intentos fallidos que lleva y envia el mensaje, sea el de repetir las opciones, o el mensaje
    # que se configura para fallos.
    def manage_failed_attempts
      # Chequea si el limite fue alcanzado. Si es asi retorna.
      return if reached_failed_attempts

      # Actualiza el customer con los intentos fallidos que lleva.
      @customer.update(failed_bot_attempts: @customer.failed_bot_attempts + 1)
      # Envia el mensaje si tienen configurado en el bot avisar que el customer ha fallado.
      @origin_instance.send_answer(@current_option, @concat_answer_type, false, false, true) &&
        return if @current_option.chat_bot.on_failed_attempt.present?
    end

    # Actualiza el customer/chat con la opcion que ha seleccionado, para saber en que paso va.
    def update_customer_flow
      return unless @selected.present?

      # Si la opcion actual ejecuta un endpoint no se resetea el contador de intentos fallidos, ya que se
      # debe esperar a ver si la respuesta es exitosa.
      failed_bot_attempts = @execute_endpoint ? @customer.failed_bot_attempts : 0
      @customer.update(active_bot: true, chat_bot_option_id: @selected.id, failed_bot_attempts: failed_bot_attempts)
    end

    # Busca si algun bot hace match con lo que envio la persona o si hay alguno con activacion
    # con cualquier interaccion
    def chat_bot_selection(text)
      chat_bots = @origin_instance.active_chat_bots
      chat_bot = chat_bots.select do |cb|
        I18n.transliterate(cb.trigger.strip.downcase) == I18n.transliterate(text.downcase)
      end&.first.presence || chat_bots.find_by_any_interaction(true)

      # Si es encontrado algun bot, chequea si este ya fue activado para el customer/chat.
      check_chat_bot_history(chat_bot) ? chat_bot : nil
    end

    # Revisa si un bot ya fue activado o no para un customer/chat. En caso de que haya sido activado
    # ya, se estudia si el bot tiene activada la reactivacion, y se ve si se le activa nuevamente, si
    # es que ya ha transcurrido el tiempo necesario. Sino se le ha activado, se le activa y ya.
    def check_chat_bot_history(chat_bot)
      return false unless chat_bot.present?

      last_interaction = @customer.chat_bot_customers.where(chat_bot_id: chat_bot.id).order(id: :desc).first

      # Si ya el customer ha interactuado con el chatbot seleccionado.
      if last_interaction.present?
        # Si la reactivacion del bot esta activa y ya ha transcurrido el tiempo establecido desde la
        # ultima vez que el customer escribio, o el agente seteo manualmente que se le activen los bots
        # al customer, entonces el bot se le activara, de otro modo no.
        if time_to_reactivate?(last_interaction, chat_bot) || @customer.allow_start_bots
          @customer.chat_bot_customers.create(chat_bot_id: chat_bot.id)
          return true
        else
          return false
        end
      end

      # Si el customer no ha interactuado con el chatbot, se le activa
      @customer.chat_bot_customers.create(chat_bot_id: chat_bot.id)
      true
    end

    # Guarda las opciones que selecciona el customer.
    def save_customer_option
      return unless @selected.present?

      @customer.customer_bot_options.create(chat_bot_option_id: @selected.id)
    end

    # Hace la comparacion entre lo que escribe la persona y las opciones del chatbot.
    def match_option(text)
      text_to_i = text.to_i
      # Solo toma las opciones hijas activas de la opcion actual.
      options = @current_option.children.active
      # Si la opciones actual es de tipo Formulario, toma la primera hija, ya que solo
      # puede tener una opcion hija este tipo de opciones.
      return options.first if @input_option

      # Se busca por posicion. Por ejemplo si la persona envia 1, 2, 3, etc...
      option = options.find_by_position(text_to_i)
      return option unless option.blank?

      # Hace una comparacion literal entre lo que escribe el customer y las opciones. Quita las
      # tildes y demas, y hace los textos minusculos para una mejor aproximacion.
      option = options.select {|option| I18n.transliterate(option.text.downcase) == I18n.transliterate(text.downcase) }.first
      return option unless option.blank?

      # Divide lo escrito por el customer por palabras, para buscar cuales tienen mayor coincidencia
      # con el texto de las opciones.
      splitted = text.split
      split_words = splitted.map { |t| I18n.transliterate(t.downcase) }
      regex = Regexp.union(split_words)
      # Toma todas las que tengan coincidencias con las palabras.
      candidates = options.select {|option| I18n.transliterate(option.text.downcase).match? regex }
      # Si hay algunas que tengan coincidencia, y si es solo una, la retorna.
      return candidates.first if candidates.present? && candidates.size == 1

      # Si hay mas de una opcion que tenga coincidencias, entonces se retorna la que tenga mas.
      # Si hay mas de una con la misma cantidad de coincidencias, entonces se cuenta como
      # intento fallido y no retorna ninguna opcion.
      count_hash = {}
      candidates.map { |c| count_hash[c.position] = I18n.transliterate(c.text.downcase).scan(regex).size }
      count_hash = count_hash.sort_by { |k, v| [-v, k] }

      option = options.find_by_position(count_hash.first[0]) if count_hash.present? &&
                                                                count_hash.first[1] != count_hash.second&.[](1)
      return option unless option.blank?

      # Al no haber ninguna opcion seleccionada, se cuenta como intento fallido.
      manage_failed_attempts
    end

    # Ejecuta las acciones de las opciones.
    # chat_bot_option = opcion a la cual se le ejecutaran las acciones
    # classification = Tipo de acciones que se ejecutaran. Valores posibles: 'default', 'success', 'failed'
    def execute_actions(chat_bot_option, classification = 'default')
      return unless chat_bot_option.present?

      # Busca las acciones a ejecutar dependiendo de la clasificacion:
      # default = acciones generales de la opcion
      # success = acciones de exito al consumir un endpoint
      # failed = acciones de fallo al consumir un endpoint
      actions = chat_bot_option.chat_bot_actions.classified(classification).order_by_action_type
      return unless actions.present?

      actions.each do |act|
        case act.action_type
        when 'add_tag'
          add_customer_tags(act)
        when 'assign_agent'
          assign_customer_agent(act)
        when 'get_out_bot'
          exit_bot
        when 'go_back_bot'
          return_bot_option
        when 'go_init_bot'
          restart_bot
        when 'save_on_db'
          save_on_table(act)
        when 'exec_callback'
          execute_callback(act, chat_bot_option)
        when 'repeat_endpoint_option'
          repeat_option
        when 'jump_to_option'
          jump_to_chat_bot_option(act)
        end
      end
    end

    # Agrega etiquetas al customer/chat
    def add_customer_tags(action)
      action_tags = action.action_tags
      return unless action_tags.present?

      tag_ids = action_tags.pluck(:tag_id).compact.uniq - @customer.tag_ids
      tag_ids.map { |ti| CustomerTag.create(customer_id: @customer.id, tag_id: ti) }
    end

    # Asigna un agente al customer/chat
    def assign_customer_agent(action)
      return unless action.retailer_user.present?

      agent_customer = @customer.agent_customer.presence || AgentCustomer.new(customer_id: @customer.id)
      agent_customer.retailer_user_id = action.retailer_user_id
      agent_customer.save
    end

    # Desactiva el chatbot. Se sale de el.
    def exit_bot
      option = @customer.chat_bot_option
      @sent_in_action = true
      @origin_instance.send_answer(option, @concat_answer_type, true)
      @origin_instance.send_additional_answers(option)
      @customer.deactivate_chat_bot!
    end

    # Retorna a la opcion anterior del chatbot.
    def return_bot_option
      option = @customer.chat_bot_option
      # Si la opcion actual no tiene padre, entonces retorna. Este es el cas de la opcion raiz.
      return unless option.has_parent?

      # Se busca el padre de la opcion actual.
      first_parent = option.parent
      return unless first_parent.has_parent?

      # Se busca el abuelo de la opcion actual, que es donde en verdad retornara.
      second_parent = first_parent.parent

      # Revisamos si la opcion destino se ignora cuando tiene ya valor almacenado.
      if skip_this_action?(second_parent)
        manage_skip_option(second_parent)
        return
      end

      @customer.update(chat_bot_option_id: second_parent.id, failed_bot_attempts: 0)
      @sent_in_action = true
      @origin_instance.send_answer(second_parent, @concat_answer_type)
      @origin_instance.send_additional_answers(second_parent)
    end

    # Reinicia el chatbot nuevamente. Lo manda al principio, a la opcion raiz.
    def restart_bot
      root = @customer.chat_bot_option.root

      # Revisamos si la opcion destino se ignora cuando tiene ya valor almacenado.
      if skip_this_action?(root)
        manage_skip_option(root)
        return
      end

      @customer.update(chat_bot_option_id: root.id, failed_bot_attempts: 0)
      @sent_in_action = true
      @origin_instance.send_answer(root, @concat_answer_type)
      @origin_instance.send_additional_answers(root)
    end

    # Guarda la informacion enviada por el customer en la base de datos.
    def save_on_table(action)
      return unless action.target_field.present?

      # Decide si guadar la opcion seleccionada de una sublista u opcion dinamica, o
      # el texto enviado por el customer.

      option = action.chat_bot_option
      value_to_save = if option.option_type == 'decision'
                        option.text
                      else
                        @selected_value.presence || @text.strip
                      end

      # Si la accion tiene asociado un campo dinamico donde se va a guardar la informacion
      # entonces se crea o se actualiza el registro de dicho campo asoaciado al customer.
      if action.customer_related_field_id.present?
        related_data = @customer.customer_related_data
          .find_or_initialize_by(customer_related_field_id: action.customer_related_field_id)

        customer_related_field = action.customer_related_field

        # Buscamos el valor interno del campo dinamico tipo lista, para guardarlo.
        # Solo en caso de ser tipo lista. Sino guardamos el valor.
        related_data.data = customer_related_field&.list? ?
          customer_related_field.get_list_option_key(value_to_save) : value_to_save
        related_data.save
      else
        # Si tiene asociado un campo existente en la tabla customers, se guarda alli.
        # En caso de fallar el guardado, se recarga el customer para que no interrumpa
        # la ejecucion del bot.
        @customer.reload unless @customer.update(action.target_field.to_sym => value_to_save)
      end
    end

    # Ejecuta un endpoint o URL externa, para mandar y traer informacion fuera de Mercately.
    def execute_callback(action, chat_bot_option)
      return unless action.webhook.present?

      body = set_body_request(action)
      endpoint_action = define_endpoint_action(action)

      response = @retailer.with_advisory_lock(@retailer.to_global_id.to_s) do
                    send(endpoint_action, action.webhook, body, set_headers(action))
                  end

      body = parse_json(response)

      # Si retorna exito el endpoint, guardamos la respuesta en el customer y borramos las respuestas
      # fallidas anteriores del endpoint y seteamos en 0 los intentos fallidos.
      if response.code == '200'
        @customer.update(endpoint_response: body, endpoint_failed_response: {}, failed_bot_attempts: 0)
        # En este punto si guardamos la opcion que selecciono el customer, ya que estamos seguros que
        # el endpoint retorno exito.
        save_customer_option
        # Decimos que en el siguiente mensaje vamos a colocar de primero la respuesta exitosa del
        # endpoint. Dato 'message'.
        @concat_answer_type = 'success'
        # Se ejecutan las acciones de exito
        execute_actions(chat_bot_option, 'success')
      else
        # Decimos que en el siguiente mensaje vamos a colocar de primero la respuesta fallida del
        # endpoint. Dato 'message'.
        @concat_answer_type = 'failed'
        # Chequeamos si ya se ha alcanzado el maximo de intentos fallidos
        if reached_failed_attempts
          @sent_in_action = true
          return
        end

        # Sino se ha alcanzado el maximo de intentos fallidos, incrementamos el contador y guardamos la
        # respuesta fallida del endpoint.
        @customer.update(endpoint_failed_response: body, failed_bot_attempts: @customer.failed_bot_attempts + 1)
        # Se ejecutan las acciones de fallo
        execute_actions(chat_bot_option, 'failed')
      end
    end

    # Reenvia la opcion en caso de que el endpoint no devuelva exito.
    def repeat_option
      return unless @current_option.present?

      @customer.update(chat_bot_option: @current_option)
      @sent_in_action = true
      @origin_instance.send_answer(@current_option, @concat_answer_type)
    end

    # Hace saltar al bot a una opcion especifica para que continue desde alli.
    # Primero chequea si la opcion actual tiene contenido para mandar el mensaje.
    # De tener, envia el mensaje y luego envia el de la opcion a donde se salta.
    def jump_to_chat_bot_option(action)
      jump_option = action.jump_option
      return unless jump_option.present?

      option = action.chat_bot_option

      if send_option_on_jump?(option)
        @origin_instance.send_answer(option, @concat_answer_type)
        @origin_instance.send_additional_answers(option)
      end

      # Revisamos si la opcion destino se ignora cuando tiene ya valor almacenado.
      if skip_this_action?(jump_option)
        manage_skip_option(jump_option)
        return
      end

      @customer.update(chat_bot_option_id: jump_option.id, failed_bot_attempts: 0)
      @sent_in_action = true
      @origin_instance.send_answer(jump_option, @concat_answer_type)
      @origin_instance.send_additional_answers(jump_option)
    end

    # En caso de que el bot tenga reactivacion, calcula si ya paso el tiempo desde la ultima vez
    # que el customer escribio, para saber si volver a activar el bot o no.
    def time_to_reactivate?(last_interaction, chat_bot)
      return false unless chat_bot.reactivate_after.present?

      if ((@origin_instance.created_at - last_interaction.created_at) / 3600).to_i >= chat_bot.reactivate_after
        # Si el customer tenia un bot activo, lo desactiva, ya que paso el tiempo de reactivacion
        # y se le debe activar de nuevo desde el inicio.
        @customer.deactivate_chat_bot!
        return true
      end

      false
    end

    # Revisa si el bot que tiene activo el customer ya esta fuera de tiempo, es decir, que ya paso
    # mas del tiempo de reactivacion desde la ultima vez que el customer escribio, y se le debe
    # desactivar.
    def chat_bot_out_of_time?
      before_last_message = @origin_instance.before_last_message
      chat_bot = @customer.chat_bot

      chat_bot && chat_bot.reactivate_after.present? && before_last_message &&
        (((@origin_instance.created_at - before_last_message.created_at) / 3600).to_i >= chat_bot.reactivate_after)
    end

    # Se selecciona la opcion a la cual se le van a ejecutar las acciones.
    def option_to_execute
      # Si la actual es de tipo Formulario, se retorna esa
      return @customer.chat_bot_option if @input_option
      # Si es de tipo Decision, se retorna la opcion seleccionada por el customer (@selected)
      return @selected if @selected&.option_type == 'decision'

      nil
    end

    # Define cual es la accion para ejecutar el endpoint. Hasta ahora es solo POST.
    def define_endpoint_action(action)
      if action.action_event == 'remove'
        'delete'
      elsif action.action_event == 'post'
        action.payload_type == 'form' ? 'post_form' : 'post'
      else
        action.action_event
      end
    end

    # Hace la comparacion entre lo que escribe la persona y la sublista de la opcion.
    def match_sub_list_items(text)
      return unless @current_option.present?

      text_to_i = text.to_i
      options = @current_option.option_sub_lists

      # Se busca por posicion. Por ejemplo si la persona envia 1, 2, 3, etc...
      option = options.find_by_position(text_to_i)
      unless option.blank?
        @selected_value = option.value_to_save
        return true
      end

      # Hace una comparacion literal entre lo que escribe el customer y las opciones. Quita las
      # tildes y demas, y hace los textos minusculos para una mejor aproximacion.
      option = options.select do |opt|
        I18n.transliterate(opt.value_to_show.downcase) == I18n.transliterate(text.downcase)
      end.first

      # Toma el valor a guardar.
      unless option.blank?
        @selected_value = option.value_to_save
        return true
      end

      # Divide lo escrito por el customer por palabras, para buscar cuales tienen mayor coincidencia
      # con el texto de las opciones.
      splitted = text.split
      split_words = splitted.map { |t| I18n.transliterate(t.downcase) }
      regex = Regexp.union(split_words)
      # Toma todas las que tengan coincidencias con las palabras.
      candidates = options.select { |opt| I18n.transliterate(opt.value_to_show.downcase).match? regex }
      # Si hay algunas que tengan coincidencia, y si es solo una, toma el valor a guardar.
      if candidates.present? && candidates.size == 1
        @selected_value = candidates.first.value_to_save
        return true
      end

      # Si hay mas de una opcion que tenga coincidencias, entonces se toma el valor de la que tenga mas.
      # Si hay mas de una con la misma cantidad de coincidencias, entonces se cuenta como
      # intento fallido y no toma ningun valor.
      count_hash = {}
      candidates.map { |c| count_hash[c.position] = I18n.transliterate(c.value_to_show.downcase).scan(regex).size }
      count_hash = count_hash.sort_by { |k, v| [-v, k] }

      option = options.find_by_position(count_hash.first[0]) if count_hash.present? &&
                                                                count_hash.first[1] != count_hash.second&.[](1)

      unless option.blank?
        @selected_value = option.value_to_save
        return true
      end

      # Al no haber ninguna opcion seleccionada, se cuenta como intento fallido.
      manage_failed_attempts
      false
    end

    # Setea el cuerpo a enviar en el endpoint.
    def set_body_request(action)
      params = {}

      action.data.each do |d|
        next unless d.key.present? && d.value.present?

        params[d.key] = set_value_param(d.value)
      end

      action.payload_type == 'json' ? params.to_query : params
    end

    # Define si el valor a setear en los parametros es uno tipeado por el agente, o lo tomara de
    # un campo de la tabla customers, o sera tomado de un campo dinamico del customer.
    def set_value_param(value)
      columns = Customer.column_names
      # Buscamos si hay algun campo dinamico que coincida con el valor del dato.
      related = @retailer.customer_related_fields.find_by_identifier(value)

      # Si lo hay, tomamos el valor de alli.
      if related.present?
        data = @customer.customer_related_data.find_by(customer_related_field_id: related.id)&.data.presence || ''
        related.field_type == 'integer' ? data.to_i : data
      elsif columns.include?(value)
        # Sino hay campo dinamico, pero si hay coincidencia con algun campo de la tabla customers, se toma
        @customer.send(value)
      else
        # Sino coincide ninguno de los anteriores, entonces tomamos el valor tal cual esta.
        value
      end
    end

    # Hace la comparacion entre lo que escribe la persona y las opciones de la opcion dinamica autogenerada.
    def match_dynamic_list(text)
      data = @customer.endpoint_response
      return unless data.present?

      text_to_i = text.to_i
      options = data.options

      # Se busca por posicion. Por ejemplo si la persona envia 1, 2, 3, etc...
      option = options.map { |opt| opt if opt.position == text_to_i }.compact.first
      unless option.blank?
        @selected_value = option.key
        return true
      end

      # Hace una comparacion literal entre lo que escribe el customer y las opciones. Quita las
      # tildes y demas, y hace los textos minusculos para una mejor aproximacion.
      option = options.map do |opt|
        opt if I18n.transliterate(opt.value.downcase) == I18n.transliterate(text.downcase)
      end.compact.first

      # Toma el valor a guardar.
      unless option.blank?
        @selected_value = option.key
        return true
      end

      # Divide lo escrito por el customer por palabras, para buscar cuales tienen mayor coincidencia
      # con el texto de las opciones.
      splitted = text.split
      split_words = splitted.map { |t| I18n.transliterate(t.downcase) }
      regex = Regexp.union(split_words)
      # Toma todas las que tengan coincidencias con las palabras.
      candidates = options.map { |opt| opt if I18n.transliterate(opt.value.downcase).match? regex }.compact
      # Si hay algunas que tengan coincidencia, y si es solo una, toma el valor a guardar.
      if candidates.present? && candidates.size == 1
        @selected_value = candidates.first.key
        return true
      end

      # Si hay mas de una opcion que tenga coincidencias, entonces se toma el valor de la que tenga mas.
      # Si hay mas de una con la misma cantidad de coincidencias, entonces se cuenta como
      # intento fallido y no toma ningun valor.
      count_hash = {}
      candidates.map { |c| count_hash[c.position] = I18n.transliterate(c.value.downcase).scan(regex).size }
      count_hash = count_hash.sort_by { |k, v| [-v, k] }

      option = options.map { |opt| opt if opt.position == count_hash.first[0] }.compact.first if count_hash.present? &&
        count_hash.first[1] != count_hash.second&.[](1)

      unless option.blank?
        @selected_value = option.key
        return true
      end

      # Al no haber ninguna opcion seleccionada, se cuenta como intento fallido.
      manage_failed_attempts
      false
    end

    def parse_json(response)
      JSON.parse(response.read_body)
    rescue
      {}
    end

    # Setea el cuerpo a enviar en el endpoint.
    def set_headers(action)
      headers = {}

      action.headers.each do |h|
        next unless h.key.present? && h.value.present?

        headers[h.key] = set_value_param(h.value)
      end

      headers
    end

    # Chequea si se han alcanzado el maximo de intentos fallidos o no. De ser alcanzados, se envia
    # el mensaje avisando y se sale del chatbot. Sino, se incrementa el contador.
    def reached_failed_attempts
      return false unless @customer.failed_bot_attempts + 1 >= @current_option.chat_bot.failed_attempts

      @customer.deactivate_chat_bot!
      @origin_instance.send_answer(@current_option, @concat_answer_type, false, true)
      true
    end

    # Busca las variables en el texto del mensaje, y las reemplaza con el valor real.
    def replace_message_variables(message)
      return message unless message.include?('{{')

      ocurrences = message.scan('{{').size

      (1..ocurrences).each do
        text = message[/\{{.*?\}}/]
        text = text.gsub('{{', '')
        text = text.gsub('}}', '')
        message[/\{{.*?\}}/] = search_variable_value(text)
      end

      message
    end

    # Define el valor a setear en la variable. Lo tomara de un campo de la tabla customers,
    # o sera tomado de un campo dinamico del customer.
    def search_variable_value(value, from = 'variable')
      value = value.strip
      columns = Customer.column_names
      # Buscamos si hay algun campo dinamico que coincida con el valor del dato.
      related = @retailer.customer_related_fields.find_by_identifier(value)

      # Si lo hay, tomamos el valor de alli.
      if related.present?
        data = @customer.customer_related_data.find_by(customer_related_field_id: related.id)&.data.presence || ''

        related.list? ? related.get_list_option_value(data) : data
      elsif columns.include?(value)
        # Sino hay campo dinamico, pero si hay coincidencia con algun campo de la tabla customers, se toma
        @customer.send(value)
      else
        # Sino coincide ninguno de los anteriores, entonces tomamos el valor tal cual esta si es que viene
        # el llamado para sustituir una variable, sino, si viene de chequear el contenido, devolvemos nil.
        from == 'variable' ? value : nil
      end
    end

    # Chequea si enviar o no el mensaje de la opcion que ejecuta la accion de saltar a otra opcion
    # es decir, de la opcion origen, antes de que haga dicho salto, y por ende antes de que mande
    # el mensaje de la opcion a la que se salta (opcion destino).
    def send_option_on_jump?(option)
      option.option_type == 'decision' && (option.answer.present? || option.file.attached? ||
        option.has_additional_answers_filled?)
    end

    # Hace una recursividad para buscar la proxima opcion que no tenga en true el atributo
    # que dice que se debe saltar a la siguiente opcion si esta ya tiene informacion guardada.
    # Y de encontrarla la envia y actualiza el flujo del customer/chat.
    def manage_skip_option(option)
      unless option.present?
        @customer.deactivate_chat_bot!
        return
      end

      # Si la opcion es de decision, o no esta seteada para saltar, o si esta seteada para saltar pero
      # no tiene valor, entonces entra en esa y manda el mensaje y actualiza el customer/chat.
      if option.option_type == 'decision' || option.skip_option == false || not_existing_option_content?(option)
        @customer.update(chat_bot_option_id: option.id, failed_bot_attempts: 0)
        @sent_in_action = true
        @origin_instance.send_answer(option, @concat_answer_type)
        @origin_instance.send_additional_answers(option)
        return
      else
        manage_skip_option(option.children.active.first)
      end
    end

    # Chequea si el campo solicitado en la accion que se desea ignorar, tiene valor o no
    # De tener, retorna false, lo que hace que siga la recursividad buscando la siguiente
    # opcion. Si no tiene, retorna true, finalizando la recursividad.
    def not_existing_option_content?(option)
      action = option.save_data_action_complete
      return true unless action.present?

      value = action.target_field.presence || action.customer_related_field&.identifier
      search_variable_value(value, 'content').blank?
    end

    # Revisa si la opcion enviada en parametros esta configurada para saltarse.
    def skip_this_action?(option)
      option&.option_type == 'form' && option&.skip_option && @sent_in_action.blank?
    end

    # Agrega la lista de opciones a seleccionar en el mensaje pasado por parametro. Dependiendo si es de tipo
    # Decision o Fomulario agrega las opciones correspondientes.
    def append_options_to_message(option, message)
      if option.option_type == 'decision'
        # Solo muestra las opciones hijas activas
        children = option.children.active

        if option.jump_to_option? == false && children.present?
          message = message.nil? ? '' : (message.present? ? message + "\n\n" : '')
          children_size = children.size - 1

          children.order(:position).each_with_index do |child, index|
            message += (child.position.to_s + '. ' + child.text)
            message += "\n" if index != children_size
          end
        end
      elsif option.has_sub_list?
        # Construye la lista de opciones a seleccionar tomando en cuenta la sublista de la opcion.
        message = message.nil? ? '' : (message.present? ? message + "\n\n" : '')
        items_size = option.option_sub_lists.size - 1

        option.option_sub_lists.order(:position).each_with_index do |item, index|
          message += (item.position.to_s + '. ' + item.value_to_show)
          message += "\n" if index != items_size
        end
      end

      message
    end
  end
end
