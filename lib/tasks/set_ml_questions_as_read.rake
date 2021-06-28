namespace :ml_questions do
  task set_questions_as_read: :environment do
    Question.where(date_read: nil).update_all(date_read: Time.now)
  end

  task set_messages_as_read: :environment do
    Message.where(date_read: nil, answer: [nil, '']).update_all(date_read: Time.now)
  end
end
