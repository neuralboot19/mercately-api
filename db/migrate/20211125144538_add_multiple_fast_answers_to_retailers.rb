class AddMultipleFastAnswersToRetailers < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :multiple_fast_answers, :boolean, default: false
  end

  def down
    remove_column :retailers, :multiple_fast_answers, :boolean
  end
end
