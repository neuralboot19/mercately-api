module MercadoLibre
  class Api
    def initialize(meli_retailer)
      @meli_retailer = meli_retailer
    end

    def prepare_search_items_url(scroll_id = nil)
      params = {
        status: 'active',
        search_type: 'scan',
        limit: 50,
        access_token: @meli_retailer.access_token
      }

      params['scroll_id'] = scroll_id if scroll_id.present?

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

    def prepare_variation_product__create_url(meli_product_id)
      params = {
        access_token: @meli_retailer.access_token
      }
      "https://api.mercadolibre.com/items/#{meli_product_id}/variations?#{params.to_query}"
    end

    def get_customer_url(customer_id)
      params = {
        access_token: @meli_retailer.access_token
      }
      "https://api.mercadolibre.com/users/#{customer_id}?#{params.to_query}"
    end

    def get_re_publish_product_url(meli_product_id)
      params = {
        access_token: @meli_retailer.access_token
      }
      "https://api.mercadolibre.com/items/#{meli_product_id}/relist?#{params.to_query}"
    end

    def get_questions_url(meli_product_id, status = nil)
      params = {
        item_id: meli_product_id,
        access_token: @meli_retailer.access_token
      }

      params['status'] = status if status.present?

      "https://api.mercadolibre.com/questions/search?#{params.to_query}"
    end

    def get_order_url(order_id)
      params = {
        access_token: @meli_retailer.access_token
      }
      "https://api.mercadolibre.com/orders/#{order_id}?#{params.to_query}"
    end

    def prepare_order_feedback_url(meli_order_id)
      params = {
        access_token: @meli_retailer.access_token
      }
      "https://api.mercadolibre.com/orders/#{meli_order_id}/feedback?#{params.to_query}"
    end

    def get_category_url(category_meli_id)
      "https://api.mercadolibre.com/categories/#{category_meli_id}"
    end

    def get_category_attributes_url(category_meli_id)
      "https://api.mercadolibre.com/categories/#{category_meli_id}/attributes"
    end
  end
end
