class AddHsTagsToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :hs_tags, :boolean, default: false
  end
end
