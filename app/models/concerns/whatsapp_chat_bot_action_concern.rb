module WhatsappChatBotActionConcern
  extend ActiveSupport::Concern
  include Whatsapp::EndpointsConnection

  included do
    after_create :chat_bot_execution
  end

  private

    def chat_bot_execution
      case self.class.name
      when 'KarixWhatsappMessage'
        return unless direction == 'inbound' && content_type == 'text'

        @text = content_text
      when 'GupshupWhatsappMessage'
        return unless direction == 'inbound' && type == 'text'

        @text = message_payload['payload'].try(:[], 'payload').try(:[], 'text') || message_payload['text']
      end

      manage_chat_bot
    end

    def manage_chat_bot
      customer.deactivate_chat_bot! if chat_bot_out_of_time?

      text = @text.strip
      if customer.active_bot
        @current_option = customer.chat_bot_option
        @input_option = @current_option&.option_type == 'form'
        @execute_endpoint = @current_option&.execute_endpoint?

        @selected = match_option(text)
        return unless @selected || @input_option

        return if @current_option&.has_sub_list? && match_sub_list_items(text) == false
        return if @current_option&.is_auto_generated? && match_dynamic_list(text) == false

        save_customer_option unless @execute_endpoint
      else
        chat_bot = chat_bot_selection(text)
        return unless chat_bot.present?

        @selected = chat_bot.chat_bot_options.first
      end

      exec_option = option_to_execute
      update_customer_flow
      execute_actions(exec_option)
      send_answer(@selected) unless @sent_in_action
    end

    def send_gupshup_notification(params)
      return unless params[:message].present?

      gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(retailer, customer)
      gws.send_message(type: params[:type], params: params)
    end

    def send_karix_notification(params)
      karix_helper = KarixNotificationHelper
      response = karix_helper.ws_message_service.send_message(retailer, customer, params, params[:type])
      return if response['error'].present?

      message = retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
      message = karix_helper.ws_message_service.assign_message(message, retailer, response['objects'][0])
      message.save

      karix_helper.broadcast_data(retailer, retailer.retailer_users.to_a, message)
    end

    def manage_failed_attempts
      return if reached_failed_attempts

      customer.update(failed_bot_attempts: customer.failed_bot_attempts + 1)
      send_answer(@current_option, false, false, true) && return if @current_option.chat_bot.on_failed_attempt.present?
    end

    def update_customer_flow
      return unless @selected.present?

      failed_bot_attempts = @execute_endpoint ? customer.failed_bot_attempts : 0
      customer.update(active_bot: true, chat_bot_option_id: @selected.id, failed_bot_attempts: failed_bot_attempts)
    end

    def send_answer(chat_bot_option, get_out = false, error_exit = false, failed_attempt = false)
      return unless chat_bot_option.present?

      params = {
        message: api.prepare_chat_bot_message(chat_bot_option, customer, get_out, error_exit, failed_attempt),
        type: 'text'
      }

      if chat_bot_option.file.attached?
        # For pdf attachments, send caption in another message
        aux_url = chat_bot_option.file_url
        if chat_bot_option.file.content_type == 'application/pdf'
          aux_url += '.pdf'

          service = "send_#{retailer.karix_integrated? ? 'karix' : 'gupshup'}_notification"
          send(service, params)
        end
        params[:type] = 'file'
        params[:content_type] = chat_bot_option.file.content_type
        params[:url] = aux_url
        # Karix service sets PDF name based on caption param
        if retailer.karix_integrated? && chat_bot_option.file.content_type == 'application/pdf'
          params[:caption] = chat_bot_option.file.blob.filename.to_s
        else
          params[:caption] = params[:message]
          params[:file_name] = chat_bot_option.file.blob.filename.to_s
        end
      end

      service = "send_#{retailer.karix_integrated? ? 'karix' : 'gupshup'}_notification"
      send(service, params)
    end

    def chat_bot_selection(text)
      chat_bots = retailer.chat_bots.enabled_ones
      chat_bot = chat_bots.select do |cb|
        I18n.transliterate(cb.trigger.strip.downcase) == I18n.transliterate(text.downcase)
      end&.first.presence || chat_bots.find_by_any_interaction(true)

      check_chat_bot_history(chat_bot) ? chat_bot : nil
    end

    def check_chat_bot_history(chat_bot)
      return false unless chat_bot.present?

      interactions = customer.chat_bot_customers.where(chat_bot_id: chat_bot.id)

      if interactions.present?
        if time_to_reactivate?(interactions, chat_bot) || customer.allow_start_bots
          customer.chat_bot_customers.create(chat_bot_id: chat_bot.id)
          return true
        else
          return false
        end
      end

      customer.chat_bot_customers.create(chat_bot_id: chat_bot.id)
      true
    end

    def save_customer_option
      return unless @selected.present?

      customer.customer_bot_options.create(chat_bot_option_id: @selected.id)
    end

    def match_option(text)
      text_to_i = text.to_i
      options = @current_option.children.active
      return options.first if @input_option

      option = options.find_by_position(text_to_i)
      return option unless option.blank?

      option = options.select {|option| I18n.transliterate(option.text.downcase) == I18n.transliterate(text.downcase) }.first
      return option unless option.blank?

      splitted = text.split
      split_words = splitted.map { |t| I18n.transliterate(t.downcase) }
      regex = Regexp.union(split_words)
      candidates = options.select {|option| I18n.transliterate(option.text.downcase).match? regex }
      return candidates.first if candidates.present? && candidates.size == 1

      count_hash = {}
      candidates.map { |c| count_hash[c.position] = I18n.transliterate(c.text.downcase).scan(regex).size }
      count_hash = count_hash.sort_by { |k, v| [-v, k] }

      option = options.find_by_position(count_hash.first[0]) if count_hash.present? &&
                                                                count_hash.first[1] != count_hash.second&.[](1)
      return option unless option.blank?

      manage_failed_attempts
    end

    def execute_actions(chat_bot_option, classification = 'default')
      return unless chat_bot_option.present?

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
        end
      end
    end

    def add_customer_tags(action)
      action_tags = action.action_tags
      return unless action_tags.present?

      tag_ids = action_tags.pluck(:tag_id).compact.uniq - customer.tag_ids
      tag_ids.map { |ti| CustomerTag.create(customer_id: customer.id, tag_id: ti) }
    end

    def assign_customer_agent(action)
      return unless action.retailer_user.present?

      agent_customer = customer.agent_customer.presence || AgentCustomer.new(customer_id: customer.id)
      agent_customer.retailer_user_id = action.retailer_user_id
      agent_customer.save
    end

    def exit_bot
      option = customer.chat_bot_option
      @sent_in_action = true
      send_answer(option, true)
      customer.deactivate_chat_bot!
    end

    def return_bot_option
      option = customer.chat_bot_option
      return unless option.has_parent?

      first_parent = option.parent
      return unless first_parent.has_parent?

      second_parent = first_parent.parent
      customer.update(chat_bot_option_id: second_parent.id, failed_bot_attempts: 0)
      @sent_in_action = true
      send_answer(second_parent)
    end

    def restart_bot
      root = customer.chat_bot_option.root
      customer.update(chat_bot_option_id: root.id, failed_bot_attempts: 0)
      @sent_in_action = true
      send_answer(root)
    end

    def save_on_table(action)
      return unless action.target_field.present?

      value_to_save = @selected_value.presence || @text.strip

      if action.customer_related_field_id.present?
        related_data = customer.customer_related_data
          .find_or_initialize_by(customer_related_field_id: action.customer_related_field_id)

        related_data.data = value_to_save
        related_data.save
      else
        customer.reload unless customer.update(action.target_field.to_sym => value_to_save)
      end
    end

    def execute_callback(action, chat_bot_option)
      return unless action.webhook.present?

      body = set_body_request(action)
      endpoint_action = define_endpoint_action(action)

      response = retailer.with_advisory_lock(retailer.to_global_id.to_s) do
                   send(endpoint_action, action.webhook, body, set_headers(action))
                 end

      body = parse_json(response)

      if response.code == '200'
        customer.update(endpoint_response: body, endpoint_failed_response: {}, failed_bot_attempts: 0)
        save_customer_option
        execute_actions(chat_bot_option, 'success')
      else
        if reached_failed_attempts
          @sent_in_action = true
          return
        end

        customer.update(endpoint_failed_response: body, failed_bot_attempts: customer.failed_bot_attempts + 1)
        execute_actions(chat_bot_option, 'failed')
      end
    end

    def repeat_option
      return unless @current_option.present?

      customer.update(chat_bot_option: @current_option)
      @sent_in_action = true
      send_answer(@current_option)
    end

    def api
      Whatsapp::Karix::Api.new
    end

    def time_to_reactivate?(interactions, chat_bot)
      return false unless chat_bot.reactivate_after.present?

      if ((created_at - interactions.last.created_at) / 3600).to_i >= chat_bot.reactivate_after
        customer.deactivate_chat_bot!
        return true
      end

      false
    end

    def chat_bot_out_of_time?
      before_last_message = customer.before_last_whatsapp_message
      chat_bot = customer.chat_bot

      chat_bot && chat_bot.reactivate_after.present? && before_last_message &&
        (((created_at - before_last_message.created_at) / 3600).to_i >= chat_bot.reactivate_after)
    end

    def option_to_execute
      return customer.chat_bot_option if @input_option
      return @selected if @selected&.option_type == 'decision'

      nil
    end

    def define_endpoint_action(action)
      if action.action_event == 'remove'
        'delete'
      elsif action.action_event == 'post'
        action.payload_type == 'form' ? 'post_form' : 'post'
      else
        action.action_event
      end
    end

    def match_sub_list_items(text)
      return unless @current_option.present?

      text_to_i = text.to_i
      options = @current_option.option_sub_lists

      option = options.find_by_position(text_to_i)
      unless option.blank?
        @selected_value = option.value_to_save
        return true
      end

      option = options.select do |opt|
        I18n.transliterate(opt.value_to_show.downcase) == I18n.transliterate(text.downcase)
      end.first

      unless option.blank?
        @selected_value = option.value_to_save
        return true
      end

      splitted = text.split
      split_words = splitted.map { |t| I18n.transliterate(t.downcase) }
      regex = Regexp.union(split_words)
      candidates = options.select { |opt| I18n.transliterate(opt.value_to_show.downcase).match? regex }
      if candidates.present? && candidates.size == 1
        @selected_value = candidates.first.value_to_save
        return true
      end

      count_hash = {}
      candidates.map { |c| count_hash[c.position] = I18n.transliterate(c.value_to_show.downcase).scan(regex).size }
      count_hash = count_hash.sort_by { |k, v| [-v, k] }

      option = options.find_by_position(count_hash.first[0]) if count_hash.present? &&
                                                                count_hash.first[1] != count_hash.second&.[](1)

      unless option.blank?
        @selected_value = option.value_to_save
        return true
      end

      manage_failed_attempts
      false
    end

    def set_body_request(action)
      params = {}

      action.data.each do |d|
        next unless d.key.present? && d.value.present?

        params[d.key] = set_value_param(d.value)
      end

      action.payload_type == 'json' ? params.to_query : params
    end

    def set_value_param(value)
      columns = Customer.column_names
      related = retailer.customer_related_fields.find_by_identifier(value)

      if related.present?
        data = customer.customer_related_data.find_by(customer_related_field_id: related.id)&.data.presence || ''
        related.field_type == 'integer' ? data.to_i : data
      elsif columns.include?(value)
        customer.send(value)
      else
        value
      end
    end

    def match_dynamic_list(text)
      data = customer.endpoint_response
      return unless data.present?

      text_to_i = text.to_i
      options = data.options

      option = options.map { |opt| opt if opt.position == text_to_i }.compact.first
      unless option.blank?
        @selected_value = option.key
        return true
      end

      option = options.map do |opt|
        opt if I18n.transliterate(opt.value.downcase) == I18n.transliterate(text.downcase)
      end.compact.first

      unless option.blank?
        @selected_value = option.key
        return true
      end

      splitted = text.split
      split_words = splitted.map { |t| I18n.transliterate(t.downcase) }
      regex = Regexp.union(split_words)
      candidates = options.map { |opt| opt if I18n.transliterate(opt.value.downcase).match? regex }.compact
      if candidates.present? && candidates.size == 1
        @selected_value = candidates.first.key
        return true
      end

      count_hash = {}
      candidates.map { |c| count_hash[c.position] = I18n.transliterate(c.value.downcase).scan(regex).size }
      count_hash = count_hash.sort_by { |k, v| [-v, k] }

      option = options.map { |opt| opt if opt.position == count_hash.first[0] }.compact.first if count_hash.present? &&
        count_hash.first[1] != count_hash.second&.[](1)

      unless option.blank?
        @selected_value = option.key
        return true
      end

      manage_failed_attempts
      false
    end

    def parse_json(response)
      JSON.parse(response.read_body)
    rescue
      {}
    end

    def set_headers(action)
      headers = {}

      action.headers.each do |h|
        next unless h.key.present? && h.value.present?

        headers[h.key] = set_value_param(h.value)
      end

      headers
    end

    def reached_failed_attempts
      return false unless customer.failed_bot_attempts + 1 >= @current_option.chat_bot.failed_attempts

      customer.deactivate_chat_bot!
      send_answer(@current_option, false, true)
      true
    end
end
