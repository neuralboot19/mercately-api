class ChatBotAction < ApplicationRecord
  belongs_to :chat_bot_option
  belongs_to :retailer_user, required: false
  has_many :action_tags, dependent: :destroy
  has_many :tags, through: :action_tags

  enum action_type: %i[add_tag assign_agent get_out_bot go_back_bot go_init_bot]
end
