class ChangeInstagramNotesNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column :gupshup_whatsapp_messages, :note, :boolean, null: false
    change_column :facebook_messages, :note, :boolean, null: false
    change_column :instagram_messages, :note, :boolean, null: false
  end
end
