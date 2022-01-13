class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :body
      t.integer :visible_for
      t.datetime :visible_until
      t.boolean :published, default: false, null: false

      t.timestamps
    end
  end
end
