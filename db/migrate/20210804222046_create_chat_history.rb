class CreateChatHistory < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_histories do |t|
      t.references :customer
      t.references :retailer_user
      t.integer :action
      t.integer :chat_status

      t.index [:customer_id, :action, :chat_status], unique: true, where: 'action = 0 AND chat_status IN (0, 1)'

      t.timestamps
    end
  end
end
