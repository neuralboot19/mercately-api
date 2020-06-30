class ChatBotOptionSerializer
  include FastJsonapi::ObjectSerializer

  set_type :chat_bot_option
  set_id :id

  attributes :id, :text, :position, :answer, :children

  attribute :children do |option|
    option.children.order(:position)
  end
end
