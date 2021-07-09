class CalendarEvent < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  belongs_to :retailer_user

  validates_presence_of :title, :starts_at, :ends_at

  before_save :calc_remember_at
  after_create :generate_web_id

  def to_param
    web_id
  end

  private

    def calc_remember_at
      time_zone = ActiveSupport::TimeZone.new(retailer.timezone.strip) if retailer.timezone.present?
      self.remember_at = if time_zone
                           time_zone.local_to_utc(starts_at)
                         else
                           time_zone = timezone.dup
                           starts_at.change(offset: time_zone.insert(3, ':'))
                         end

      self.remember_at -= remember.minutes
    end
end
