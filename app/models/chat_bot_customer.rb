class ChatBotCustomer < ApplicationRecord
  belongs_to :customer
  belongs_to :chat_bot

  scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }
end
