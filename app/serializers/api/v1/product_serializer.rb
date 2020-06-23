module Api::V1
  class ProductSerializer
    include FastJsonapi::ObjectSerializer

    set_type :product
    set_id :id

    attributes :id, :title, :description, :url, :available_quantity, :price

    attribute :image do |product|
      url = "http://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/"
      key = product.main_picture_id ? product.images&.find(product.main_picture_id)&.key : product.images&.first&.key
      key.present? ? url += key : url = nil
      url
    end
  end
end
