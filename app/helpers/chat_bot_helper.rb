module ChatBotHelper
  def action_events_list
    exceptions = [:get, :put, :patch, :remove]

    ChatBotAction.action_events.except(*exceptions).keys.collect do |a|
      [ChatBotAction.enum_translation(:action_event, a), a]
    end
  end

  def option_types_list
    ChatBotOption.option_types.keys.collect { |a| [ChatBotOption.enum_translation(:option_type, a), a] }
  end

  def payload_types_list
    exceptions = [:form]

    ChatBotAction.payload_types.except(*exceptions).keys.collect do |a|
      [ChatBotAction.enum_translation(:payload_type, a), a]
    end
  end

  def action_types_list(classification)
    except_actions = case classification
                     when 'default'
                       [:auto_generate_option, :repeat_endpoint_option]
                     when 'success'
                       [:exec_callback, :repeat_endpoint_option, :go_back_bot]
                     when 'failed'
                       [:exec_callback, :auto_generate_option]
                     end

    ChatBotAction.action_types.except(*except_actions).keys.collect do |a|
      [ChatBotAction.enum_translation(:action_type, a), a]
    end
  end

  def on_failed_attempts_list
    ChatBot.on_failed_attempts.keys.collect { |o| [ChatBot.enum_translation(:on_failed_attempt, o), o] }
  end
end
