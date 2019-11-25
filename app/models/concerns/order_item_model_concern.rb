module OrderItemModelConcern
  extend ActiveSupport::Concern

  # Chequea si el sold quantity se puede decrementar
  def subtract_sold_quantity?
    change_sold_quantity == false && from_ml?
  end
end
