class CreateAgentNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :agent_notifications do |t|
      t.belongs_to :customer, foreign_key: true, null: false
      t.belongs_to :retailer_user, foreign_key: true, index: true, null: false
      t.string :notification_type
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
