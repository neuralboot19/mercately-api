class AddHsIdToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :hs_id, :string

    Retailer.where.not(hs_access_token: nil).find_each do |r|
      hs = HubspotService::Api.new(r.hs_access_token)
      hs_id = hs.me['portalId']
      r.update hs_id: hs_id
    end
  end
end
