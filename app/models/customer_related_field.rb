class CustomerRelatedField < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  has_many :customer_related_data, dependent: :destroy
  has_many :chat_bot_actions

  validates :name, presence: true
  validates :identifier, uniqueness: { scope: :retailer_id, message: 'Campo ya está en uso.' },
    allow_blank: false

  enum field_type: %i[string integer float boolean date list]

  before_validation :set_identifier, on: :create
  before_destroy :check_destroy_requirements
  before_save :clear_options_list
  after_create :generate_web_id

  def to_param
    web_id
  end

  def list_options
    read_attribute(:list_options).map { |l| ListOption.new(l) }
  end

  def list_options_attributes=(attributes)
    list_options = []
    attributes.each do |index, attrs|
      list_options << attrs
    end

    write_attribute(:list_options, list_options)
  end

  class ListOption
    attr_accessor :key, :value

    def initialize(data = {})
      @key = data['key'] || ''
      @value = data['value'] || ''
    end

    def persisted?
      false
    end
  end

  # Retorna el key de la opcion filtrada por el valor.
  def get_list_option_key(value)
    key = list_options.find { |l|
      I18n.transliterate(l.value.strip.downcase) == I18n.transliterate(value.strip.downcase)
    }&.key

    key.presence || value
  end

  # Retorna el value de la opcion filtrada por el key.
  def get_list_option_value(key)
    value = list_options.find { |l|
      I18n.transliterate(l.key.strip.downcase) == I18n.transliterate(key.strip.downcase)
    }&.value

    value.presence || key
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

    def clear_options_list
      return if field_type == 'list'

      write_attribute(:list_options, [])
    end
end
