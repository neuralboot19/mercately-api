class AddSendMaxSizePdfsAndImagesToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :send_max_size_files, :boolean, default: false, null: false
  end
end
