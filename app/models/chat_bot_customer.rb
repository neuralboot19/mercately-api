class ChatBotCustomer < ApplicationRecord
  belongs_to :customer
  belongs_to :chat_bot
end
