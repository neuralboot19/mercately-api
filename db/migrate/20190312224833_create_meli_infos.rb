class CreateMeliInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :meli_infos do |t|
      t.string :access_token
      t.string :meli_user_id
      t.string :refresh_token
      t.references :retailer, foreign_key: true

      t.timestamps
    end
  end
end
