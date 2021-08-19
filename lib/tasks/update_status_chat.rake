namespace :customers do
  task update_status_chat_messenger: :environment do
    Customer.where.not(psid: [nil, '']).update_all(status_chat: 'in_process')
  end

  task update_status_chat_whatsapp: :environment do
    Customer.where(ws_active: true).update_all(status_chat: 'in_process')
  end
end
