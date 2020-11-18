class AddEndpointResponseToCustomer < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :endpoint_response, :jsonb, default: {}
    add_column :customers, :endpoint_failed_response, :jsonb, default: {}
  end

  def down
    remove_column :customers, :endpoint_response, :jsonb
    remove_column :customers, :endpoint_failed_response, :jsonb
  end
end
