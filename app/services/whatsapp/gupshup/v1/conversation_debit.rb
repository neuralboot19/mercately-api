module Whatsapp::Gupshup::V1
  class ConversationDebit < Base
    def track_conversation(message, params)
      conversation = params['payload']['conversation']
      pricing = params['payload']['pricing']

      if conversation.blank? && pricing.blank?
        check_free_conversation(message, params)
        return
      end

      return unless conversation.present? && conversation['id'] != @customer.current_conversation

      @customer.update_column(:current_conversation, conversation['id'])
      attrs = {
        conversation_payload: params['payload'],
        initiate_conversation: true,
        conversation_type: get_conversation_type(conversation['type']),
        whatsapp_message_id: message.whatsapp_message_id.presence || params['payload']['id']
      }

      message.update_columns(attrs)

      # type = pricing&.[]('category') || conversation&.[]('type')
      # return unless type.present?

      # time = Time.now
      # retailer_ws_conv = @retailer.retailer_whatsapp_conversations.find_or_create_by(year: time.year, month: time.month)

      # price_attrs = if type == 'UIC'
      #                 { user_initiated_total: retailer_ws_conv.user_initiated_total + 1 }
      #               elsif type == 'BIC'
      #                 { business_initiated_total: retailer_ws_conv.business_initiated_total + 1 }
      #               else
      #                 { free_point_total: retailer_ws_conv.free_point_total + 1 }
      #               end

      # retailer_ws_conv.update(price_attrs)
    end

    def process_debit(message, params)
      deductions = params['payload']['deductions']
      return unless deductions.present?

      case deductions['model']
      when 'CBP'
        # Se ejecuta cobro de conversacion
        time = Time.now
        retailer_ws_conv = @retailer.retailer_whatsapp_conversations.find_or_create_by(year: time.year, month: time.month)

        if (retailer_ws_conv.free_bic_total + retailer_ws_conv.free_uic_total) < 1000 && deductions['type'] != 'FEP'
          count_free_conversations(retailer_ws_conv, deductions['type'])
          return
        end

        country_ws_conv = retailer_ws_conv.country_conversations.find_or_create_by(country_code: @customer.country_id)

        amount = @customer.get_conversation_cost(deductions['type'])
        @retailer.update_column(:ws_balance, @retailer.ws_balance - amount)
        message&.update_column(:cost, amount)

        case deductions['type']
        when 'UIC'
          price_attrs = {
            user_initiated_total: retailer_ws_conv.user_initiated_total + 1,
            user_initiated_cost: retailer_ws_conv.user_initiated_cost + amount
          }

          country_attrs = {
            total_uic: country_ws_conv.total_uic + 1,
            total_cost_uic: country_ws_conv.total_cost_uic + amount
          }
        when 'BIC'
          price_attrs = {
            business_initiated_total: retailer_ws_conv.business_initiated_total + 1,
            business_initiated_cost: retailer_ws_conv.business_initiated_cost + amount
          }

          country_attrs = {
            total_bic: country_ws_conv.total_bic + 1,
            total_cost_bic: country_ws_conv.total_cost_bic + amount
          }
        when 'FEP'
          price_attrs = { free_point_total: retailer_ws_conv.free_point_total + 1 }
        end

        retailer_ws_conv.update(price_attrs)
        country_ws_conv.update(country_attrs)
      when 'NBP'
        # Se ejecuta cobro de plantilla
        amount = @customer.ws_notification_cost
        @retailer.update(ws_balance: @retailer.ws_balance - amount)
        message&.update_column(:cost, amount)
      end
    end

    def get_conversation_type(type)
      case type
      when 'FEP'
        'free_point'
      when 'UIC'
        'user_initiated'
      when 'BIC'
        'business_initiated'
      end
    end

    def check_free_conversation(message, params)
      time = Time.now
      retailer_ws_conv = @retailer.retailer_whatsapp_conversations.find_or_create_by(year: time.year, month: time.month)
      return if (retailer_ws_conv.free_bic_total + retailer_ws_conv.free_uic_total) >= 1000

      block = @retailer.message_blocks.find_by_phone(message.destination)
      if block.present?
        return unless ((message.created_at.localtime - block.sent_date.localtime) / 3600) >= 24

        block.update(sent_date: message.created_at)
      else
        @retailer.message_blocks.create(phone: message.destination, sent_date: message.created_at)
      end

      if message.message_type == 'conversation'
        retailer_ws_conv.update(free_uic_total: retailer_ws_conv.free_uic_total + 1)
      else
        retailer_ws_conv.update(free_bic_total: retailer_ws_conv.free_bic_total + 1)
      end
    end

    def count_free_conversations(retailer_ws_conv, type)
      price_attrs = case type
                    when 'UIC'
                      { free_uic_total: retailer_ws_conv.free_uic_total + 1 }
                    when 'BIC'
                      { free_bic_total: retailer_ws_conv.free_bic_total + 1 }
                    end

      retailer_ws_conv.update(price_attrs)
    end
  end
end
