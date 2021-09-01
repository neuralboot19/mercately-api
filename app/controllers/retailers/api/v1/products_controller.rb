module Retailers::Api::V1
  class ProductsController < Retailers::Api::V1::ApiController
    before_action :check_ownership, only: [:show, :update]
    before_action :validate_images, only: [:create, :update]

    def index
      total = current_retailer.products.count
      page = params[:page] ? params[:page] : 1
      products = current_retailer.products.order(created_at: :desc).page(page.to_i).per(100)

      render status: 200, json: {
        total: total,
        total_pages: products.total_pages,
        products: serialize_products(products)
      }
    end

    def show
      render status: 200, json: {
        message: 'Product found successfully',
        product: Retailers::Api::V1::ProductSerializer.new(@product)
      }
    end

    def create
      @product = current_retailer.products.new(product_params.except(:status))

      if @product.save
        process_images(params.try(:[], :product).try(:[], :image_urls))
        render status: 200, json: {
          message: 'Product created successfully',
          product: Retailers::Api::V1::ProductSerializer.new(@product)
        }
      else
        render status: :unprocessable_entity, json: {
          message: 'Error creating product',
          errors: @product.errors.full_messages
        }
      end
    end

    def update
      if @product.update(product_params)
        process_images(params.try(:[], :product).try(:[], :image_urls))
        render status: 200, json: {
          message: 'Product updated successfully',
          product: Retailers::Api::V1::ProductSerializer.new(@product)
        }
      else
        render status: :unprocessable_entity, json: {
          message: 'Error updating product',
          errors: @product.errors.full_messages
        }
      end
    end

    private

      def product_params
        params.require(:product).permit(
          :title,
          :price,
          :available_quantity,
          :url,
          :description,
          :status
        )
      end

      def check_ownership
        @product = Product.find_by(web_id: params[:id])
        render status: 404, json: { message: "Product not found" } unless @product &&
          current_retailer.products.exists?(@product.id)
      end

      def process_images(images)
        return unless images.present?

        images.each_with_index do |url, index|
          next unless url.present?

          filename = url[url.rindex('/') + 1, url.size - 1]
          @product.attach_image(url, filename, index)
        end
      end

      def validate_images
        images = params.try(:[], :product).try(:[], :image_urls)
        return if images.blank? || images.size <= 3

        render status: :bad_request, json: {
          message: 'Maximum three (3) images allowed'
        }
      end

      def serialize_products(products)
        ActiveModelSerializers::SerializableResource.new(
          products,
          each_serializer: Retailers::Api::V1::ProductSerializer
        )
      end
  end
end
