class CreateRetailerUnfinishedMessageBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :retailer_unfinished_message_blocks do |t|
      t.references :retailer, foreign_key: true
      t.references :customer, foreign_key: true
      t.datetime :message_created_date
      t.string :direction
      t.boolean :sent_by_retailer
      t.integer :platform
      t.date :message_date

      t.timestamps
    end
  end
end
