module TemplatesControllerConcern
  extend ActiveSupport::Concern

  def resize_image
    return unless params[:template][:image].present?

    image = params[:template][:image]
    content_type = MIME::Types.type_for(image.tempfile.path).first.content_type
    return unless content_type.include?('image/')

    params[:template][:image].tempfile = process_file(image)
  end

  def check_additional_attachments
    params[:template][:additional_fast_answers_attributes]&.each do |afa|
      file = afa[1][:file]

      if afa[1][:id].present? && (afa[1][:file_deleted] == 'true' || file.present?)
        additional = AdditionalFastAnswer.find_by_id(afa[1][:id])
        additional.file.purge if additional.file.attached?
      end

      if file.present?
        content_type = MIME::Types.type_for(file.tempfile.path).first.content_type

        if content_type.include?('image/')
          type = 'image'
          afa[1][:file].tempfile = process_file(file)
        else
          type = 'file'
        end

        afa[1][:file_type] = type
      end

      afa[1][:file_type] = nil if afa[1][:file_deleted] == 'true' && !file
    end
  end

  private

    def process_file(file)
      tempfile = MiniMagick::Image.open(File.open(file.tempfile))
      return file.tempfile if tempfile.width <= 1000 && tempfile.height <= 1000

      width = tempfile.width > 1000 ? 1000 : tempfile.width
      height = tempfile.height > 1000 ? 1000 : tempfile.height

      tempfile.resize "#{width}x#{height}"
      tempfile.tempfile
    end
end
