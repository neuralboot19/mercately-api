class CreateGlobalSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :global_settings do |t|
      t.string :setting_key
      t.string :value

      t.timestamps
    end
  end
end
