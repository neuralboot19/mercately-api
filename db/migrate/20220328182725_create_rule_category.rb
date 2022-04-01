class CreateRuleCategory < ActiveRecord::Migration[5.2]
  def change
    create_table :rule_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
