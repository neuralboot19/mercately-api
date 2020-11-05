class TreeOptionSerializer < ActiveModel::Serializer
  attributes :id, :answer, :text, :position, :option_type, :children, :auto_generated

  def children
    return @instance_options[:children]
  end

  def auto_generated
    object.is_auto_generated?
  end
end
