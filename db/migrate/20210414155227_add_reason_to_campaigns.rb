class AddReasonToCampaigns < ActiveRecord::Migration[5.2]
  def change
    add_column :campaigns, :reason, :string
  end
end
