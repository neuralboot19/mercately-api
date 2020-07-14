class ChatBotOption < ApplicationRecord
  has_ancestry
  belongs_to :chat_bot
  has_many :chat_bot_actions, dependent: :destroy
  has_many :customer_bot_options, dependent: :destroy
  has_many :customers, through: :customer_bot_options

  before_create :set_position

  accepts_nested_attributes_for :chat_bot_actions, reject_if: :all_blank, allow_destroy: true

  private

    def set_position
      self.position = self.parent.present? ? self.parent.children.size + 1 : 0
    end
end
