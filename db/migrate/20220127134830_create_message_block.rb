class CreateMessageBlock < ActiveRecord::Migration[5.2]
  def change
    create_table :message_blocks do |t|
      t.references :retailer
      t.string :phone
      t.datetime :sent_date

      t.index [:retailer_id, :phone], unique: true

      t.timestamps
    end
  end
end
