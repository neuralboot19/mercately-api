class Reminder < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  belongs_to :customer
  belongs_to :retailer_user
  belongs_to :whatsapp_template
  belongs_to :gupshup_whatsapp_message, required: false
  belongs_to :karix_whatsapp_message, required: false
  has_one_attached :file

  validates_presence_of :send_at, :timezone

  enum status: %i[scheduled sent cancelled failed]

  before_create :calculate_send_timezone
  after_create :generate_web_id

  def to_param
    web_id
  end

  def file_url
    "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{file.key}"
  end

  private

    def calculate_send_timezone
      time_zone = timezone.dup
      self.send_at_timezone = send_at.change(offset: time_zone.insert(3, ':'))
    end
end
