class AddIndexToImages < ActiveRecord::Migration[5.2]
  def up
    add_index :active_storage_blobs, [:filename, :checksum], unique: true
  end

  def down
    remove_index :active_storage_blobs, [:filename, :checksum]
  end
end
