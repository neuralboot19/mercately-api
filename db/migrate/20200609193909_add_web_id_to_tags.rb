class AddWebIdToTags < ActiveRecord::Migration[5.2]
  def up
    add_column :tags, :web_id, :string

    letters = ('a'..'z').to_a
    Tag.all.each do |t|
      t.update_column(:web_id, t.retailer.id.to_s + letters.sample(5).join + t.id.to_s)
    end
  end

  def down
    remove_column :tags, :web_id, :string
  end
end
