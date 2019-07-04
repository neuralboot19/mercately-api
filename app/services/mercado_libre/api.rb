module MercadoLibre
  class Api
    def initialize(meli_retailer)
      @meli_retailer = meli_retailer
    end

    def prepare_search_items_url
      params = {
        access_token: @meli_retailer.access_token
      }
      "https://api.mercadolibre.com/users/#{@meli_retailer.meli_user_id}/items/search?#{params.to_query}"
    end

    def get_product_url(product)
      params = {
        access_token: @meli_retailer.access_token
      }
      "https://api.mercadolibre.com/items/#{product}/?#{params.to_query}"
    end

    def get_product_description_url(product)
      params = {
        access_token: @meli_retailer.access_token
      }
      "https://api.mercadolibre.com/items/#{product}/description?#{params.to_query}"
    end

    def prepare_products_creation_url
      params = {
        access_token: @meli_retailer.access_token
      }
      "https://api.mercadolibre.com/items?#{params.to_query}"
    end

    def prepare_load_pictures_url
      params = {
        access_token: @meli_retailer.access_token
      }
      "https://api.mercadolibre.com/pictures?#{params.to_query}"
    end

    def prepare_link_pictures_to_product_url(product)
      params = {
        access_token: @meli_retailer.access_token
      }
      "https://api.mercadolibre.com/items/#{product.meli_product_id}/pictures?#{params.to_query}"
    end
  end
end
