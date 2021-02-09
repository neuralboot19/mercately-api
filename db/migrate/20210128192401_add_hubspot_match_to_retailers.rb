class AddHubspotMatchToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :hubspot_match, :integer, default: 0
  end
end
