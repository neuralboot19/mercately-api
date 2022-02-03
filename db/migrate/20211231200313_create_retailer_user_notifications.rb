class CreateRetailerUserNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :retailer_user_notifications do |t|
      t.references :retailer_user, foreign_key: true
      t.references :notification, foreign_key: true
      t.boolean :seen, default: false, null: false

      t.timestamps
    end
  end
end
