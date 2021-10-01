class CreateImportContactsLogger < ActiveRecord::Migration[5.2]
  def change
    create_table :import_contacts_loggers do |t|
      t.integer :retailer_user_id
      t.integer :retailer_id
      t.string :original_file_name

      t.timestamps
    end
  end
end
