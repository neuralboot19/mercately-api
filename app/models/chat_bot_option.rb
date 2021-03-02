class ChatBotOption < ApplicationRecord
  has_ancestry
  belongs_to :chat_bot
  has_many :chat_bot_actions, dependent: :destroy
  has_many :customer_bot_options, dependent: :destroy
  has_many :customers, through: :customer_bot_options
  has_many :option_sub_lists, dependent: :destroy
  has_many :additional_bot_answers, dependent: :destroy
  has_one_attached :file

  before_destroy :check_destroy_requirements
  before_create :set_position
  before_save :check_skip_option
  after_save :update_descendants_on_delete
  after_save :clear_endpoint_actions
  after_save :clear_sub_list
  after_update :reassign_positions, if: :saved_change_to_option_deleted?

  attribute :file_deleted, :boolean

  accepts_nested_attributes_for :chat_bot_actions, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :option_sub_lists, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :additional_bot_answers, reject_if: :all_blank, allow_destroy: true

  enum option_type: %i[decision form]

  scope :active, -> { where(option_deleted: false) }

  def file_url
    if file.content_type.include?('video/')
      "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/video/upload/#{self.file.key}"
    else
      "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{self.file.key}"
    end
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

  def jump_to_option?
    chat_bot_actions.where(action_type: :jump_to_option).exists?
  end

  def save_data_action_complete
    action = chat_bot_actions.find_by_action_type(:save_on_db)
    return unless action.present? && (action.target_field.present? || action.customer_related_field.present?)

    action
  end

  def has_additional_answers_filled?
    additional_bot_answers.with_attached_file.each do |aba|
      return true if aba.text.present? || aba.file.attached?
    end

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

    def check_skip_option
      self.skip_option = false if option_type == 'decision'
    end
end
