class AddTagColorToTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :tag_color, :string, default: "#ffffff00"
    add_column :tags, :font_color, :string, default: "#B2B3BD"
  end
end
