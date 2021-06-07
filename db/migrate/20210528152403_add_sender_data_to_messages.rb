class AddSenderDataToMessages < ActiveRecord::Migration[5.2]
  def up
    add_column :gupshup_whatsapp_messages, :sender_first_name, :string
    add_column :gupshup_whatsapp_messages, :sender_last_name, :string
    add_column :gupshup_whatsapp_messages, :sender_email, :string

    add_column :karix_whatsapp_messages, :sender_first_name, :string
    add_column :karix_whatsapp_messages, :sender_last_name, :string
    add_column :karix_whatsapp_messages, :sender_email, :string

    add_column :facebook_messages, :sender_first_name, :string
    add_column :facebook_messages, :sender_last_name, :string
    add_column :facebook_messages, :sender_email, :string
  end

  def down
    remove_column :gupshup_whatsapp_messages, :sender_first_name, :string
    remove_column :gupshup_whatsapp_messages, :sender_last_name, :string
    remove_column :gupshup_whatsapp_messages, :sender_email, :string

    remove_column :karix_whatsapp_messages, :sender_first_name, :string
    remove_column :karix_whatsapp_messages, :sender_last_name, :string
    remove_column :karix_whatsapp_messages, :sender_email, :string

    remove_column :facebook_messages, :sender_first_name, :string
    remove_column :facebook_messages, :sender_last_name, :string
    remove_column :facebook_messages, :sender_email, :string
  end
end
