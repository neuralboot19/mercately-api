class AddApiCreatedToCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :api_created, :boolean, default: false
  end
end
