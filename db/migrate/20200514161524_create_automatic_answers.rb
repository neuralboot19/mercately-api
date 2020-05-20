class CreateAutomaticAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :automatic_answers do |t|
      t.references :retailer
      t.string :message
      t.integer :message_type
      t.integer :interval
      t.integer :status, default: 1
      t.integer :platform

      t.timestamps
    end
  end
end
