class MeliRetailer < ApplicationRecord
  belongs_to :retailer
  after_save :update_information

  def update_information
    if has_meli_info == false || self.updated_at > DateTime.current + 3.days
      MercadoLibre::Retailer.new(self.retailer).update_retailer_info
    end
  end
end
