class ChatBot < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  has_many :chat_bot_options, dependent: :destroy
  has_many :chat_bot_customers, dependent: :destroy
  has_many :customers, through: :chat_bot_customers

  validate :any_interaction_unique
  validate :required_activation_data

  after_create :generate_web_id

  accepts_nested_attributes_for :chat_bot_options, reject_if: :all_blank, allow_destroy: true

  scope :enabled_ones, -> { where(enabled: true) }

  def to_param
    web_id
  end

  private

    def any_interaction_unique
      return unless any_interaction == true

      cb_aux = retailer.chat_bots.where(any_interaction: true)
      exist_other = if new_record?
                      cb_aux.exists?
                    else
                      cb_aux.where.not(id: id).exists?
                    end

      errors.add(:base, 'Ya existe un ChatBot activado con cualquier interacción') if exist_other
    end

    def required_activation_data
      return unless enabled == true

      errors.add(:base, 'Debe ingresar un texto de activación o activar con cualquier interacción') if trigger.blank? &&
        any_interaction != true
    end
end
