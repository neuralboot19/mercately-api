class AddPlatformsToAutomaticAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :automatic_answers, :whatsapp, :boolean, default: false
    add_column :automatic_answers, :messenger, :boolean, default: false
    add_column :automatic_answers, :instagram, :boolean, default: false
    add_column :automatic_answers, :always_active, :boolean, default: true
  end
end
