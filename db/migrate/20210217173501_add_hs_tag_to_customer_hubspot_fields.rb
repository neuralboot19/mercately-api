class AddHsTagToCustomerHubspotFields < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_hubspot_fields, :hs_tag, :boolean, default: false
  end
end
