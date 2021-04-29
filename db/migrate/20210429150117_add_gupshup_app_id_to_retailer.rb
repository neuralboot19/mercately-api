class AddGupshupAppIdToRetailer < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :gupshup_app_id, :string
    add_column :retailers, :gupshup_app_token, :string
  end

  def down
    remove_column :retailers, :gupshup_app_id, :string
    remove_column :retailers, :gupshup_app_token, :string
  end
end
