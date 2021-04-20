class AddMlSiteToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :ml_site, :string, default: 'MEC'
  end
end
