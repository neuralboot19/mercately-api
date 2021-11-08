module Api::V1
  class TemplateSerializer
    include FastJsonapi::ObjectSerializer

    set_type :template
    set_id :id

    attributes :id, :title, :answer, :file_type

    attribute :image_url do |object|
      next unless object.image.attached?

      "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{object.image.key}"
    end

    attribute :file_name do |object|
      next unless object.image.attached?

      object.image.filename.to_s
    end
  end
end
