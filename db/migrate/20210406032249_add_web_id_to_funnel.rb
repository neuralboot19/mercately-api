class AddWebIdToFunnel < ActiveRecord::Migration[5.2]
  def change
    add_column :funnels, :web_id, :string
  end
end
