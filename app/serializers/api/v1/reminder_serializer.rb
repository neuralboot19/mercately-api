module Api::V1
  class ReminderSerializer < ActiveModel::Serializer
    attributes :id, :web_id, :template_text, :status, :send_at

    def send_at
      object.send_at&.strftime('%d/%m/%Y %I:%M %P')
    end
  end
end
