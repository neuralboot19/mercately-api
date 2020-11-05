class CreateOptionSubList < ActiveRecord::Migration[5.2]
  def change
    create_table :option_sub_lists do |t|
      t.references :chat_bot_option
      t.string :value_to_save
      t.string :value_to_show
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
