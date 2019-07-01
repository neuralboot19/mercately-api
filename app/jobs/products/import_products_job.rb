module Products
  class ImportProductsJob < ApplicationJob
    queue_as :critical

    def perform(retailer_id)
      @retailer = Retailer.find(retailer_id)
      set_ml_products

      @ml_products.search_items
    end

    private

      def set_ml_products
        @ml_products = MercadoLibre::Products.new(@retailer)
      end
  end
end
