module WhatsappChatBotActionConcern
  extend ActiveSupport::Concern

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
      text = @text.strip
      if customer.active_bot
        selected = match_option(text)
        return unless selected

        save_customer_option(selected)
      else
        chat_bot = chat_bot_selection(text)
        return unless chat_bot.present?

        selected = chat_bot.chat_bot_options.first
      end

      update_customer_flow(selected)
      execute_actions(selected)
      send_answer(selected) unless @sent_in_action
    end

    def send_gupshup_notification(params)
      return unless params[:message].present?

      gws = Whatsapp::Gupshup::V1::Outbound::Msg.new(retailer, customer)
      gws.send_message(type: 'text', params: params)
    end

    def send_karix_notification(params)
      karix_helper = KarixNotificationHelper
      response = karix_helper.ws_message_service.send_message(retailer, customer, params, 'text')
      return if response['error'].present?

      message = retailer.karix_whatsapp_messages.find_or_initialize_by(uid: response['objects'][0]['uid'])
      message = karix_helper.ws_message_service.assign_message(message, retailer, response['objects'][0])
      message.save

      karix_helper.broadcast_data(retailer, retailer.retailer_users.to_a, message)
    end

    def manage_failed_attempts
      chat_bot_option = customer.chat_bot_option
      if customer.failed_bot_attempts + 1 >= chat_bot_option.chat_bot.failed_attempts
        customer.update(active_bot: false, chat_bot_option_id: nil, failed_bot_attempts: 0, allow_start_bots: false)
        send_answer(chat_bot_option, false, true)
        return
      end

      customer.update(failed_bot_attempts: customer.failed_bot_attempts + 1)
      send_answer(chat_bot_option) && return if chat_bot_option.chat_bot.repeat_menu_on_failure
    end

    def update_customer_flow(selected)
      return unless selected.present?

      customer.update(active_bot: true, chat_bot_option_id: selected.id, failed_bot_attempts: 0)
    end

    def send_answer(selected, get_out = false, error_exit = false)
      params = {
        message: api.prepare_chat_bot_message(selected, get_out, error_exit)
      }

      service = "send_#{retailer.karix_integrated? ? 'karix' : 'gupshup'}_notification"
      send(service, params)
    end

    def chat_bot_selection(text)
      chat_bots = retailer.chat_bots.enabled_ones
      chat_bot = chat_bots.select { |cb| cb.trigger.strip.downcase == text.downcase }&.first.presence ||
                 chat_bots.find_by_any_interaction(true)

      check_chat_bot_history(chat_bot) ? chat_bot : nil
    end

    def check_chat_bot_history(chat_bot)
      return false unless chat_bot.present?
      return customer.allow_start_bots if customer.chat_bot_customers.where(chat_bot_id: chat_bot.id).exists?

      customer.chat_bot_customers.create(chat_bot_id: chat_bot.id)
      true
    end

    def save_customer_option(selected)
      customer.customer_bot_options.create(chat_bot_option_id: selected.id)
    end

    def match_option(text)
      text_to_i = text.to_i
      options = customer.chat_bot_option.children.active

      option = options.find_by_position(text_to_i)
      return option unless option.blank?

      option = options.where('lower(text) = ?', text.downcase).first
      return option unless option.blank?

      splitted = text.split
      split_words = splitted.map { |t| "%#{t}%" }
      candidates = options.where('text ILIKE ANY (array[?])', split_words)
      return candidates.first if candidates.present? && candidates.size == 1

      count_hash = {}
      regex = /#{splitted.join('|')}/i
      candidates.map { |c| count_hash[c.position] = c.text.scan(regex).size }
      count_hash = count_hash.sort_by { |k, v| [-v, k] }

      option = options.find_by_position(count_hash.first[0]) if count_hash.present? &&
                                                                count_hash.first[1] != count_hash.second&.[](1)
      return option unless option.blank?

      manage_failed_attempts
    end

    def execute_actions(chat_bot_option)
      actions = chat_bot_option.chat_bot_actions.order(:action_type)
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
      customer.update(active_bot: false, chat_bot_option_id: nil, failed_bot_attempts: 0, allow_start_bots: false)
      @sent_in_action = true
      send_answer(option, true)
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

    def api
      Whatsapp::Karix::Api.new
    end
end
