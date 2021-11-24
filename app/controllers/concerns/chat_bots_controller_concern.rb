module ChatBotsControllerConcern
  extend ActiveSupport::Concern

  def resize_images
    params[:chat_bot][:chat_bot_options_attributes].each do |cbo_param|
      file = cbo_param[1][:file]
      cbo_param[1][:file].tempfile = resize(file) if check_is_image(file)

      cbo_param[1][:additional_bot_answers_attributes]&.each do |aba_param|
        file = aba_param[1][:file]
        next unless file.present?
        next unless check_is_image(file)

        aba_param[1][:file].tempfile = resize(file)
      end
    end
  end

  def check_is_image(file)
    return false unless file.present?

    content_type = MIME::Types.type_for(file.tempfile.path).first.content_type
    content_type.include?('image/')
  end

  def resize(file)
    tempfile = MiniMagick::Image.open(File.open(file.tempfile))
    return file.tempfile if tempfile.width <= 1000 && tempfile.height <= 1000

    width = tempfile.width > 1000 ? 1000 : tempfile.width
    height = tempfile.height > 1000 ? 1000 : tempfile.height

    tempfile.resize "#{width}x#{height}"
    tempfile.tempfile
  end
end
