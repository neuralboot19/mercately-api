class AssignFirstLastNameToCustomers < ActiveRecord::Migration[5.2]
  def up
    Customer.where.not(full_name: nil).where(first_name: nil).each do |c|
      arr = c.full_name.split(' ')

      if arr.size == 1
        c.update_column(:first_name, arr[0])
      elsif arr.size == 2
        c.update_columns(first_name: arr[0], last_name: arr[1])
      elsif arr.size == 3
        c.update_columns(first_name: arr[0..1].join(' '), last_name: arr[2])
      elsif arr.size == 4
        c.update_columns(first_name: arr[0..1].join(' '), last_name: arr[2..3].join(' '))
      elsif arr.size > 4
        c.update_columns(first_name: arr[0..1].join(' '), last_name: arr[2..arr.size - 1].join(' '))
      end
    end

    remove_column :customers, :full_name, :string
  end

  def down
    add_column :customers, :full_name, :string
  end
end
