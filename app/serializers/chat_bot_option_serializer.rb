class ChatBotOptionSerializer
  include FastJsonapi::ObjectSerializer

  set_type :chat_bot_option
  set_id :id

  attributes :id, :text, :position, :answer, :option_type, :children, :auto_generated

  attribute :children do |option|
    option.children.active.order(:position)
  end

  attribute :auto_generated do |option|
    option.is_auto_generated?
  end

  attribute :option_sub_list do |option|
    next [] if option.option_type == 'decision'

    option.option_sub_lists.order(:position)
  end
end
