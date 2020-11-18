class ChatBotOption < ApplicationRecord
  has_ancestry
  belongs_to :chat_bot
  has_many :chat_bot_actions, dependent: :destroy
  has_many :customer_bot_options, dependent: :destroy
  has_many :customers, through: :customer_bot_options
  has_many :option_sub_lists, dependent: :destroy
  has_one_attached :file

  before_destroy :check_destroy_requirements
  before_create :set_position
  after_save :update_descendants_on_delete
  after_save :clear_form_actions
  after_save :clear_endpoint_actions
  after_save :clear_sub_list
  after_update :reassign_positions, if: :saved_change_to_option_deleted?

  attribute :file_deleted, :boolean

  accepts_nested_attributes_for :chat_bot_actions, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :option_sub_lists, reject_if: :all_blank, allow_destroy: true

  enum option_type: %i[decision form]

  scope :active, -> { where(option_deleted: false) }

  def file_url
    "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{self.file.key}"
  end

  def execute_endpoint?
    chat_bot_actions.where(action_type: :exec_callback).exists?
  end

  def has_sub_list?
    option_sub_lists.present?
  end

  def is_auto_generated?
    return parent.chat_bot_actions.where(action_type: :auto_generate_option).exists? if parent.present?

    false
  end

  private

    def set_position
      self.position = self.parent.present? ? self.parent.children.active.size + 1 : 0
    end

    def check_destroy_requirements
      throw(:abort)
    end

    def update_descendants_on_delete
      return unless option_deleted == true

      self.descendants.update_all(option_deleted: true)
    end

    def clear_form_actions
      return if option_type == 'form'

      self.chat_bot_actions.where(action_type: :save_on_db).delete_all
    end

    def clear_endpoint_actions
      return if execute_endpoint?

      self.chat_bot_actions.where(classification: ['success', 'failed']).delete_all
    end

    def reassign_positions
      return unless option_deleted

      self.parent.children.active.order(:id).except(self).each_with_index do |cbo, index|
        cbo.update_column(:position, index + 1)
      end
    end

    def clear_sub_list
      return if option_type == 'form'

      self.option_sub_lists.delete_all
    end
end
