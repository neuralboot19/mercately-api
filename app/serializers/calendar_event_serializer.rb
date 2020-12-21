class CalendarEventSerializer < ActiveModel::Serializer
  attributes :id, :title, :remember
  attribute :web_id, key: :id
  attribute :starts_at, key: :start
  attribute :ends_at, key: :end
end
