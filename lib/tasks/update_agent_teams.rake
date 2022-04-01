namespace :agent_teams do
  task update_status: :environment do
    agent_ids = AgentTeam.where(active: false).pluck(:retailer_user_id).uniq
    RetailerUser.where(id: agent_ids).update_all(active: false)
    AgentTeam.where(retailer_user_id: agent_ids).update_all(active: false)
  end
end
