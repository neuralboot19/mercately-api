class RemoveRemindersField < ActiveRecord::Migration[5.2]
  def change
    remove_column :retailers, :show_calendar, :boolean, default: false
    remove_column :retailers, :allow_reminders, :boolean, default: false
  end
end
