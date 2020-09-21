class AddAllowVoiceNotesToRetailer < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :allow_voice_notes, :boolean, default: false
  end

  def down
    remove_column :retailers, :allow_voice_notes, :boolean
  end
end
