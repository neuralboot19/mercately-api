class AddListOptionsToCustomerRelatedFields < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_related_fields, :list_options, :jsonb, default: []
  end
end
