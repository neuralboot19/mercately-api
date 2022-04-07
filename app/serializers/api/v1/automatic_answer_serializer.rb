module Api::V1
  class AutomaticAnswerSerializer < ActiveModel::Serializer
    attributes :id, :message, :message_type, :whatsapp, :messenger, :instagram,
      :interval, :always_active, :automatic_answer_days

    def automatic_answer_days
      ActiveModelSerializers::SerializableResource.new(
        object.automatic_answer_days,
        each_serializer: AutomaticAnswerDaySerializer
      )
    end
  end
end
