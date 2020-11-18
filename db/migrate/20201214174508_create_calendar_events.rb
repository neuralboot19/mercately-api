class CreateCalendarEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :calendar_events do |t|
      t.references :retailer, foreign_key: true
      t.string :title
      t.datetime :starts_at
      t.datetime :ends_at
      t.datetime :remember_at
      t.references :retailer_user, foreign_key: true

      t.timestamps
    end
  end
end
