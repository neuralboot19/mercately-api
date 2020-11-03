class SetDefaultSomeValuesToRetailer < ActiveRecord::Migration[5.2]
  def change
    change_column :retailers, :ws_conversation_cost, :float, default: 0.0
    change_column :retailers, :int_charges, :boolean, default: true
    change_column :retailers, :allow_voice_notes, :boolean, default: true
  end
end
