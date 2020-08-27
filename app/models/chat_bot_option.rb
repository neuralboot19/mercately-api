class ChatBotOption < ApplicationRecord
  has_ancestry
  belongs_to :chat_bot
  has_many :chat_bot_actions, dependent: :destroy
  has_many :customer_bot_options, dependent: :destroy
  has_many :customers, through: :customer_bot_options

  before_destroy :check_destroy_requirements
  before_create :set_position
  after_save :update_descendants_on_delete

  accepts_nested_attributes_for :chat_bot_actions, reject_if: :all_blank, allow_destroy: true

  scope :active, -> { where(option_deleted: false) }

  private

    def set_position
      self.position = self.parent.present? ? self.parent.children.size + 1 : 0
    end

    def check_destroy_requirements
      throw(:abort)
    end

    def update_descendants_on_delete
      return unless option_deleted == true

      self.descendants.update_all(option_deleted: true)
    end
end
