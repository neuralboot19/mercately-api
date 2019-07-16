class AddMainPictureToProducts < ActiveRecord::Migration[5.2]
  def up
    add_column :products, :main_picture_id, :bigint, default: nil
  end

  def down
    remove_column :products, :main_picture_id, :bigint, default: nil
  end
end
