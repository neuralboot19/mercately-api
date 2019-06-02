class MeliRetailer < ApplicationRecord
  belongs_to :retailer
  after_save :update_information

  private

    def update_information
      return if has_meli_info == false || updated_at > DateTime.current + 3.days

      MercadoLibre::Retailer.new(retailer).update_retailer_info
    end
end
