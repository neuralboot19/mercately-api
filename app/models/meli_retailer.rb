class MeliRetailer < ApplicationRecord
  belongs_to :retailer
  after_save :update_information

  def self.check_unique_meli_user_id(meli_user_id)
    MeliRetailer.exists?(meli_user_id: meli_user_id.to_s)
  end

  private

    def update_information
      return if meli_info_updated_at.present? && meli_info_updated_at > DateTime.current - 7.days

      MercadoLibre::Retailer.new(retailer).update_retailer_info
    end
end
