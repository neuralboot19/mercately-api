class Api::V1::ProductsController < ApplicationController
  include CurrentRetailer
  before_action :authenticate_retailer_user!

  def index
    products = current_retailer.products.where('title ILIKE ? OR description ILIKE ?',
      "%#{params[:search]}%", "%#{params[:search]}%").page(params[:page]).per(25)

    serialized = Api::V1::ProductSerializer.new(products)

    if products.present?
      render status: 200, json: { products: serialized, total_pages: products.total_pages }
    else
      render status: 404, json: { products: serialized, total_pages: products.total_pages, message:
        'No existen productos' }
    end
  end
end
