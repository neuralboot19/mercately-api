class AddTeamAssignmentToAction < ActiveRecord::Migration[5.2]
  def up
    add_reference :chat_bot_actions, :team_assignment
  end

  def down
    remove_reference :chat_bot_actions, :team_assignment
  end
end
