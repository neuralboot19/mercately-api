class CustomerBotOption < ApplicationRecord
  belongs_to :customer
  belongs_to :chat_bot_option
end
