class ChatBotOptionSerializer
  include FastJsonapi::ObjectSerializer

  set_type :chat_bot_option
  set_id :id

  attributes :id, :text, :position, :answer, :option_type, :children, :auto_generated

  attribute :children do |option|
    option.children.active.order(:position)
  end

  attribute :auto_generated do |option|
    option.is_auto_generated?
  end

  attribute :option_sub_list do |option|
    next [] if option.option_type == 'decision'

    option.option_sub_lists.order(:position)
  end

  attribute :additional_bot_answers do |option|
    additional_answers = option.additional_bot_answers.with_attached_file.order(id: :asc).presence || []
    next additional_answers if additional_answers.blank?

    AdditionalBotAnswerPreviewSerializer.new(additional_answers)
  end

  attribute :type do |option|
    next 'text' unless option.file.attached?

    content_type = option.file.content_type
    if content_type == 'application/pdf'
      'pdf'
    elsif content_type.include? 'image/'
      'image'
    elsif content_type.include? 'video/'
      'video'
    end
  end

  attribute :file_url do |option|
    next unless option.file.attached?

    option.file_url
  end

  attribute :filename do |option|
    next unless option.file.attached?

    option.file.filename.to_s
  end

  attribute :jump_to_option do |option|
    option.jump_to_option?
  end
end
