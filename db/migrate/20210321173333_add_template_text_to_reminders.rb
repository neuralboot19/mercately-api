class AddTemplateTextToReminders < ActiveRecord::Migration[5.2]
  def change
    add_column :reminders, :template_text, :text
    Reminder.all.find_each do |r|
      r.send(:generate_template_text)
    end
  end
end
