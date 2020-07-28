class AddGupShupApiKeyToRetailer < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :gupshup_api_key, :string

    old_int_retailers = Retailer.where(whats_app_enabled: true).where.not(gupshup_phone_number: nil, gupshup_src_name: nil)
      .where.not("(id = 464 OR id = 308)")

    new_int_retailers = Retailer.where(whats_app_enabled: true)
      .where.not(gupshup_phone_number: nil, gupshup_src_name: nil, id: old_int_retailers.ids)

    old_int_retailers.update_all(gupshup_api_key: 'e7f36ebc9eb941b3c11e0499ad388f67')

    new_int_retailers.update_all(gupshup_api_key: 'f7d7dde221634702c7f010707acbfe24')
  end

  def down
    remove_column :retailers, :gupshup_api_key, :string
  end
end
