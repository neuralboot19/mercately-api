module TemplatesControllerConcern
  extend ActiveSupport::Concern

  def resize_image
    return unless params[:template][:image].present?

    image = params[:template][:image]
    content_type = MIME::Types.type_for(image.tempfile.path).first.content_type
    return unless content_type.include?('image/')

    tempfile = MiniMagick::Image.open(File.open(image.tempfile))
    return if tempfile.width <= 1000 && tempfile.height <= 1000

    width = tempfile.width > 1000 ? 1000 : tempfile.width
    height = tempfile.height > 1000 ? 1000 : tempfile.height

    tempfile.resize "#{width}x#{height}"
    params[:template][:image].tempfile = tempfile.tempfile
  end
end
