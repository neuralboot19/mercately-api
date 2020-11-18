class AddShowCalendarToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :show_calendar, :boolean, default: false
  end
end
