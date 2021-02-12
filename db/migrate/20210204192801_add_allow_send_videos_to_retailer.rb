class AddAllowSendVideosToRetailer < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :allow_send_videos, :boolean, default: false
  end

  def down
    remove_column :retailers, :allow_send_videos, :boolean
  end
end
