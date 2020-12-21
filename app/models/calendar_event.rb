class CalendarEvent < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  belongs_to :retailer_user

  validates_presence_of :title, :starts_at, :ends_at

  before_validation :calc_remember_at
  after_create :generate_web_id

  def to_param
    web_id
  end

  private

    def calc_remember_at
      time_zone = timezone.dup
      self.remember_at = starts_at.change(offset: time_zone.insert(3, ':'))
      self.remember_at -= remember.minutes
    end
end
