class AdditionalBotAnswerPreviewSerializer
  include FastJsonapi::ObjectSerializer

  set_type :additional_bot_answer
  set_id :id

  attributes :id, :text

  attribute :type do |aba|
    next 'text' unless aba.file.attached?

    content_type = aba.file.content_type
    if content_type == 'application/pdf'
      'pdf'
    elsif content_type.include? 'image/'
      'image'
    elsif content_type.include? 'video/'
      'video'
    end
  end

  attribute :file_url do |aba|
    next unless aba.file.attached?

    aba.file_url
  end

  attribute :filename do |aba|
    next unless aba.file.attached?

    aba.file.filename.to_s
  end
end
