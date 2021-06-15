class AddWebIdToFunnelStep < ActiveRecord::Migration[5.2]
  def change
    add_column :funnel_steps, :web_id, :string
  end
end
