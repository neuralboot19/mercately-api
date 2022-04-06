FactoryBot.define do
  factory :automatic_answer_day do
    automatic_answer
    day { Time.new.wday }
    start_time {5.hours.ago.localtime.hour}
    end_time {5.hours.after.localtime.hour}
    all_day {false}
  end
end
