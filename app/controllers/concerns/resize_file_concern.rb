module ResizeFileConcern
  extend ActiveSupport::Concern

  def resize_file
    instance = if params[:reminder].present?
                 :reminder
               elsif params[:campaign].present?
                 :campaign
               end

    return unless params[instance][:file].present?

    file = params[instance][:file]
    content_type = MIME::Types.type_for(file.tempfile.path).first.content_type
    return unless content_type.include?('image/')

    tempfile = MiniMagick::Image.open(File.open(file.tempfile))
    return if tempfile.width <= 1000 && tempfile.height <= 1000

    width = tempfile.width > 1000 ? 1000 : tempfile.width
    height = tempfile.height > 1000 ? 1000 : tempfile.height

    tempfile.resize "#{width}x#{height}"
    params[instance][:file].tempfile = tempfile.tempfile
  end
end
