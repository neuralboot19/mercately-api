module Api::V1
  class TemplateSerializer
    include FastJsonapi::ObjectSerializer

    set_type :template
    set_id :id

    attributes :id, :title, :answer

    attribute :image_url do |object|
      next unless object.image.attached?

      "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{object.image.key}"
    end
  end
end
