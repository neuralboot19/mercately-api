class CreateGupshupPartner < ActiveRecord::Migration[5.2]
  def change
    create_table :gupshup_partners do |t|
      t.integer :partner_id
      t.string :name
      t.string :token

      t.timestamps
    end
  end
end
