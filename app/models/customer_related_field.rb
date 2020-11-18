class CustomerRelatedField < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  has_many :customer_related_data, dependent: :destroy
  has_many :chat_bot_actions

  validates :name, presence: true
  validates :identifier, uniqueness: { scope: :retailer_id, message: 'Campo ya está en uso.' },
    allow_blank: false

  enum field_type: %i[string integer]

  before_validation :set_identifier, on: :create
  before_destroy :check_destroy_requirements
  after_create :generate_web_id

  def to_param
    web_id
  end

  private

    def set_identifier
      self.identifier = name.parameterize(separator: '_')
    end

    def check_destroy_requirements
      return unless chat_bot_actions.present?

      errors.add(:base, 'Campo no se puede eliminar, posee acciones asociadas')
      throw(:abort)
    end
end
