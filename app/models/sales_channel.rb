class SalesChannel < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  has_many :orders

  enum channel_type: %i[other mercadolibre whatsapp messenger]

  validates_presence_of :title, message: 'Título no puede estar vacío'

  before_destroy :check_destroy_requirements
  after_create :generate_web_id

  def to_param
    web_id
  end

  private

    def check_destroy_requirements
      if channel_type != 'other'
        errors.add(:base, 'Canal no se puede eliminar, pertenece a una integración')
        throw(:abort)
      end

      return unless orders.present?

      errors.add(:base, 'Canal no se puede eliminar, posee ventas asociadas')
      throw(:abort)
    end
end
