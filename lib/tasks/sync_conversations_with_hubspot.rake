namespace :retailers do
  task sync_conversations: :environment do
    Retailers::RetailersSyncConversationsJob.perform_later
  end
end