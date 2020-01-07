class AddExtraFieldsToFacebookMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :facebook_messages, :date_read, :date
    add_column :facebook_messages, :sent_from_mercately, :boolean, default: false
  end
end
