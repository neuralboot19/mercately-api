class AddWebIdToCalendarEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :calendar_events, :web_id, :string
    add_column :calendar_events, :remember, :integer
  end
end
