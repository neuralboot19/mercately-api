class AddCustomerIdToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_reference :questions, :customer
  end
end
