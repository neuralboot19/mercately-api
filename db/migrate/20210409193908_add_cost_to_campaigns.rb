class AddCostToCampaigns < ActiveRecord::Migration[5.2]
  def change
    add_column :campaigns, :cost, :float, default: 0.0
  end
end
