class AddAllowRemindersToRetailer < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :allow_reminders, :boolean, default: false
  end

  def down
    remove_column :retailers, :allow_reminders, :boolean
  end
end
