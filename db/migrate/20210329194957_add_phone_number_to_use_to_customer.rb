class AddPhoneNumberToUseToCustomer < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :number_to_use, :string
  end

  def down
    remove_column :customers, :number_to_use, :string
  end
end
