class AddWebIdToRetailers < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :web_id, :string, index: true

    letters = ('a'..'z').to_a
    Retailer.all.each do |r|
      wi = r.id.to_s + letters.shuffle[0,5].join
      r.update(web_id: wi)
    end
  end

  def down
    remove_column :retailers, :web_id, :string
  end
end
