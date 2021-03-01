class TreeOptionSerializer < ActiveModel::Serializer
  attributes :id, :answer, :text, :position, :option_type, :children, :auto_generated, :jump_option_name

  def children
    return @instance_options[:children]
  end

  def auto_generated
    object.is_auto_generated?
  end

  def jump_option_name
    jump_action = object.chat_bot_actions.find_by(action_type: :jump_to_option)
    return '' unless jump_action.present?

    jump_action.jump_option&.text || ''
  end
end
