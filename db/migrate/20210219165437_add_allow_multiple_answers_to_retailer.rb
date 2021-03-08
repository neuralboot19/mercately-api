class AddAllowMultipleAnswersToRetailer < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :allow_multiple_answers, :boolean, default: false
  end

  def down
    remove_column :retailers, :allow_multiple_answers, :boolean
  end
end
