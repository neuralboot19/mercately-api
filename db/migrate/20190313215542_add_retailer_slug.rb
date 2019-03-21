class AddRetailerSlug < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :slug, :string
    add_index :retailers, :slug, unique: true

    Retailer.all.each do |retailer|
      retailer.generate_slug
    end
  end

  def down
    remove_column :retailers, :slug
  end
end
