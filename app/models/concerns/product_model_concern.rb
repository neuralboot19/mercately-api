module ProductModelConcern
  extend ActiveSupport::Concern

  # Chequea si es posible mandar la informacion a ML
  def able_to_send_to_ml?
    meli_product_id.present? || upload_product == true
  end
end
