class AddFailedBotAttemptsToCustomer < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :failed_bot_attempts, :integer, default: 0
    add_column :customers, :allow_start_bots, :boolean, default: false
  end

  def down
    remove_column :customers, :failed_bot_attempts, :integer
    remove_column :customers, :allow_start_bots, :boolean
  end
end
