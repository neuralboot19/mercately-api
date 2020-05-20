class FacebookCatalog < ApplicationRecord
  belongs_to :retailer
  validates_uniqueness_of :uid, message: 'Catálogo ya está asociado con una cuenta de Mercately', allow_blank: true
  validates_uniqueness_of :business_id, message: 'Administrador de negocio ya está asociado con' \
    ' una cuenta de Mercately', allow_blank: true

  def connected?
    uid.present?
  end
end
