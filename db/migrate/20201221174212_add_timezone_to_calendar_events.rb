class AddTimezoneToCalendarEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :calendar_events, :timezone, :string
  end
end
