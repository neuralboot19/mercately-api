class CreateMeliCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :meli_customers do |t|
      t.string :access_token
      t.string :meli_user_id
      t.string :refresh_token
      t.string :nickname
      t.string :email
      t.integer :points
      t.string :link
      t.string :seller_experience
      t.string :seller_reputation_level_id
      t.integer :transactions_canceled
      t.integer :transactions_completed
      t.integer :ratings_negative
      t.integer :ratings_neutral
      t.integer :ratings_positive
      t.integer :ratings_total
      t.references :customer, foreign_key: true
      t.string :phone

      t.timestamps
    end
  end
end
