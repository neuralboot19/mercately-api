class AddMlDomainToRetailers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailers, :ml_domain, :string, default: 'com.ec'
  end
end
