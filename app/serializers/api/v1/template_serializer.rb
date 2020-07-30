module Api::V1
  class TemplateSerializer
    include FastJsonapi::ObjectSerializer

    set_type :template
    set_id :id

    attributes :id, :title, :answer, :image_url

    attribute :image_url do |object|
      next unless object.image.attached?

      "http://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{object.image.key}"
    end
  end
end
