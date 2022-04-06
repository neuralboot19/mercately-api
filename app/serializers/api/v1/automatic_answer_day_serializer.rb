module Api::V1
  class AutomaticAnswerDaySerializer < ActiveModel::Serializer
    attributes :id, :day, :all_day, :start_time, :end_time
  end
end