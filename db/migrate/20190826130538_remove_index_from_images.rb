class RemoveIndexFromImages < ActiveRecord::Migration[5.2]
  def up
    remove_index :active_storage_blobs, [:filename, :checksum]
  end

  def down
    add_index :active_storage_blobs, [:filename, :checksum], unique: true
  end
end
