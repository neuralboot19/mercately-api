class CreateCustomerBotOption < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_bot_options do |t|
      t.references :customer
      t.references :chat_bot_option

      t.timestamps
    end
  end
end
