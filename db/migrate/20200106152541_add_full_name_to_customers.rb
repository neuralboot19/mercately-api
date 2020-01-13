class AddFullNameToCustomers < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :full_name, :string

    Customer.all.each do |c|
      next if c.first_name.blank? && c.last_name.blank?

      c.update_column(:full_name, "#{c.first_name} #{c.last_name}".strip)
    end
  end

  def down
    remove_column :customers, :full_name, :string
  end
end
