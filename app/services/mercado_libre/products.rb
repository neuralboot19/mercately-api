module MercadoLibre
  class Products

    def initialize(retailer)
      @retailer = retailer
      @meli_info = @retailer.meli_info
    end

    def search_items
      url = prepare_search_items_url
      conn = Faraday.new(url: url) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to $stdout
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      response = conn.get
      response = JSON.parse(response.body)
      products_to_import = response['results']
      import_product(products_to_import)
    end

    def import_product(products)
      products.each do |product|
        byebug
        url = prepare_products_search_url(product)
        byebug
        conn = Faraday.new(url: url) do |faraday|
          faraday.request  :url_encoded             # form-encode POST params
          faraday.response :logger                  # log requests to $stdout
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end
        byebug
        response = conn.get
        byebug
        response = JSON.parse(response.body)
      end
    end

    private

      def prepare_search_items_url
        params = {
          access_token: @meli_info.access_token,
        }
        "https://api.mercadolibre.com/users/#{@meli_info.meli_user_id}/items/search?#{params.to_query}"
      end

      def prepare_products_search_url(product)
        params = {
          access_token: @meli_info.access_token,
        }
        "https://api.mercadolibre.com/items/#{product}/?#{params.to_query}"
      end
  end
end


# {
#     "seller_id": "418940513",
#     "query": null,
#     "paging": {
#         "limit": 50,
#         "offset": 0,
#         "total": 1
#     },
#     "results": [
#         "MEC419833558"
#     ],
#     "filters": [],
#     "available_filters": [
#         {
#             "id": "status",
#             "name": "Status",
#             "values": [
#                 {
#                     "id": "pending",
#                     "name": "Inactive items for debt or MercadoLibre policy violation",
#                     "results": 0
#                 },
#                 {
#                     "id": "not_yet_active",
#                     "name": "Items newly created or pending activation",
#                     "results": 0
#                 },
#                 {
#                     "id": "programmed",
#                     "name": "Items scheduled for future activation",
#                     "results": 0
#                 },
#                 {
#                     "id": "active",
#                     "name": "Active items",
#                     "results": 1
#                 },
#                 {
#                     "id": "paused",
#                     "name": "Paused Items",
#                     "results": 0
#                 },
#                 {
#                     "id": "closed",
#                     "name": "Closed Items",
#                     "results": 0
#                 }
#             ]
#         },
#         {
#             "id": "sub_status",
#             "name": "Substatus",
#             "values": [
#                 {
#                     "id": "deleted",
#                     "name": "Deleted substatus",
#                     "results": 0
#                 },
#                 {
#                     "id": "forbidden",
#                     "name": "Forbidden substatus",
#                     "results": 0
#                 },
#                 {
#                     "id": "freezed",
#                     "name": "Freezed substatus",
#                     "results": 0
#                 },
#                 {
#                     "id": "held",
#                     "name": "Held substatus",
#                     "results": 0
#                 },
#                 {
#                     "id": "suspended",
#                     "name": "Suspended substatus",
#                     "results": 0
#                 },
#                 {
#                     "id": "waiting_for_patch",
#                     "name": "Waiting for patch substatus",
#                     "results": 0
#                 },
#                 {
#                     "id": "warning",
#                     "name": "Warning items with MercadoLibre policy violation",
#                     "results": 0
#                 }
#             ]
#         },
#         {
#             "id": "buying_mode",
#             "name": "Buying Mode",
#             "values": [
#                 {
#                     "id": "buy_it_now",
#                     "name": "Buy it now",
#                     "results": 1
#                 },
#                 {
#                     "id": "classified",
#                     "name": "Classified",
#                     "results": 0
#                 },
#                 {
#                     "id": "auction",
#                     "name": "Auction",
#                     "results": 0
#                 }
#             ]
#         },
#         {
#             "id": "listing_type_id",
#             "name": "Listing type",
#             "values": [
#                 {
#                     "id": "gold_pro",
#                     "name": "Gold proffesional",
#                     "results": 0
#                 },
#                 {
#                     "id": "gold_special",
#                     "name": "Gold special",
#                     "results": 0
#                 },
#                 {
#                     "id": "gold_premium",
#                     "name": "Gold premium",
#                     "results": 0
#                 },
#                 {
#                     "id": "gold",
#                     "name": "Gold",
#                     "results": 0
#                 },
#                 {
#                     "id": "silver",
#                     "name": "Silver",
#                     "results": 0
#                 },
#                 {
#                     "id": "bronze",
#                     "name": "Bronze",
#                     "results": 0
#                 },
#                 {
#                     "id": "free",
#                     "name": "Free",
#                     "results": 1
#                 }
#             ]
#         },
#         {
#             "id": "shipping_free_methods",
#             "name": "Shipping free methods",
#             "values": []
#         },
#         {
#             "id": "shipping_tags",
#             "name": "Shipping Tags",
#             "values": []
#         },
#         {
#             "id": "shipping_mode",
#             "name": "Shipping Mode",
#             "values": [
#                 {
#                     "id": "not_specified",
#                     "results": 1
#                 }
#             ]
#         },
#         {
#             "id": "listing_source",
#             "name": "Listing Source",
#             "values": [
#                 {
#                     "id": "tucarro",
#                     "name": "TuCarro",
#                     "results": 0
#                 },
#                 {
#                     "id": "tuinmueble",
#                     "name": "TuInmueble",
#                     "results": 0
#                 },
#                 {
#                     "id": "tumoto",
#                     "name": "TuMoto",
#                     "results": 0
#                 },
#                 {
#                     "id": "tulancha",
#                     "name": "TuLancha",
#                     "results": 0
#                 },
#                 {
#                     "id": "autoplaza",
#                     "name": "Autoplaza",
#                     "results": 0
#                 },
#                 {
#                     "id": "autoplaza_ml",
#                     "name": "Autoplaza Premium",
#                     "results": 0
#                 }
#             ]
#         },
#         {
#             "id": "labels",
#             "name": "Others",
#             "values": [
#                 {
#                     "id": "few_available",
#                     "name": "Items with few availables",
#                     "results": 0
#                 },
#                 {
#                     "id": "with_bids",
#                     "name": "Items with bids",
#                     "results": 0
#                 },
#                 {
#                     "id": "without_bids",
#                     "name": "Items whithout bids",
#                     "results": 1
#                 },
#                 {
#                     "id": "accepts_mercadopago",
#                     "name": "Items with MercadoPago",
#                     "results": 0
#                 },
#                 {
#                     "id": "ending_soon",
#                     "name": "Items ending in 20 days or less",
#                     "results": 0
#                 },
#                 {
#                     "id": "with_mercadolibre_envios",
#                     "name": "Items with MercadoLibre Envíos",
#                     "results": 0
#                 },
#                 {
#                     "id": "without_mercadolibre_envios",
#                     "name": "Items without MercadoLibre Envíos",
#                     "results": 1
#                 },
#                 {
#                     "id": "with_low_quality_image",
#                     "name": "Items with low quality image",
#                     "results": 0
#                 },
#                 {
#                     "id": "with_free_shipping",
#                     "name": "Items with free shipping",
#                     "results": 1
#                 },
#                 {
#                     "id": "without_free_shipping",
#                     "name": "Items with free shipping",
#                     "results": 0
#                 },
#                 {
#                     "id": "with_automatic_relist",
#                     "name": "Items with automatic relist",
#                     "results": 0
#                 },
#                 {
#                     "id": "waiting_for_payment",
#                     "name": "Items waiting for payment",
#                     "results": 0
#                 },
#                 {
#                     "id": "suspended",
#                     "name": "Suspended items",
#                     "results": 0
#                 },
#                 {
#                     "id": "cancelled",
#                     "name": "Items cancelled that can not be recovered",
#                     "results": 0
#                 },
#                 {
#                     "id": "being_reviewed",
#                     "name": "Items under review",
#                     "results": 0
#                 },
#                 {
#                     "id": "fix_required",
#                     "name": "Items waiting for user fix",
#                     "results": 0
#                 },
#                 {
#                     "id": "waiting_for_documentation",
#                     "name": "Items waiting for user documentation",
#                     "results": 0
#                 },
#                 {
#                     "id": "without_stock",
#                     "name": "Paused items that are out of stock",
#                     "results": 0
#                 },
#                 {
#                     "id": "incomplete_technical_specs",
#                     "name": "Items with incomplete technical specs",
#                     "results": 0
#                 },
#                 {
#                     "id": "loyalty_discount_eligible",
#                     "name": "Loyalty discount eligible items",
#                     "results": 0
#                 },
#                 {
#                     "id": "with_fbm_contingency",
#                     "name": "Items in FBM contingency",
#                     "results": 0
#                 },
#                 {
#                     "id": "with_shipping_self_service",
#                     "name": "Items with shipping self service logistic",
#                     "results": 0
#                 }
#             ]
#         },
#         {
#             "id": "logistic_type",
#             "name": "Logistic Type",
#             "values": [
#                 {
#                     "id": "not_specified",
#                     "results": 1
#                 }
#             ]
#         }
#     ],
#     "orders": [
#         {
#             "id": "stop_time_asc",
#             "name": "Order by stop time ascending"
#         }
#     ],
#     "available_orders": [
#         {
#             "id": "stop_time_asc",
#             "name": "Order by stop time ascending"
#         },
#         {
#             "id": "stop_time_desc",
#             "name": "Order by stop time descending"
#         },
#         {
#             "id": "start_time_asc",
#             "name": "Order by start time ascending"
#         },
#         {
#             "id": "start_time_desc",
#             "name": "Order by start time descending"
#         },
#         {
#             "id": "available_quantity_asc",
#             "name": "Order by available quantity ascending"
#         },
#         {
#             "id": "available_quantity_desc",
#             "name": "Order by available quantity descending"
#         },
#         {
#             "id": "sold_quantity_asc",
#             "name": "Order by sold quantity ascending"
#         },
#         {
#             "id": "sold_quantity_desc",
#             "name": "Order by sold quantity descending"
#         },
#         {
#             "id": "price_asc",
#             "name": "Order by price ascending"
#         },
#         {
#             "id": "price_desc",
#             "name": "Order by price descending"
#         },
#         {
#             "id": "last_updated_desc",
#             "name": "Order by lastUpdated descending"
#         },
#         {
#             "id": "last_updated_asc",
#             "name": "Order by last updated ascending"
#         },
#         {
#             "id": "total_sold_quantity_asc",
#             "name": "Order by total sold quantity ascending"
#         },
#         {
#             "id": {
#                 "id": "total_sold_quantity_desc",
#                 "field": "sold_quantity",
#                 "missing": "_last",
#                 "order": "desc"
#             },
#             "name": "Order by total sold quantity descending"
#         },
#         {
#             "id": {
#                 "id": "inventory_id_asc",
#                 "field": "inventory_id",
#                 "missing": "_last",
#                 "order": "asc"
#             },
#             "name": "Order by inventory id ascending"
#         }
#     ]
# }