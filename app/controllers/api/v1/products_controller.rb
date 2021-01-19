class Api::V1::ProductsController < Api::ApiController
  include CurrentRetailer

  def index
    products = current_retailer.products.where('title ILIKE :search OR description ILIKE :search OR code ILIKE :search',
      search: "%#{params[:search]}%").page(params[:page]).per(25)

    serialized = Api::V1::ProductSerializer.new(products)

    if products.present?
      render status: 200, json: { products: serialized, total_pages: products.total_pages }
    else
      render status: 404, json: { products: serialized, total_pages: products.total_pages, message:
        'No existen productos' }
    end
  end
end
