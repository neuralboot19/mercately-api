class ActionTag < ApplicationRecord
  belongs_to :chat_bot_action
  belongs_to :tag
end
