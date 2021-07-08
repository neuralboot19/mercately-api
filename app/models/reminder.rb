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
  before_create :generate_template_text
  after_create :generate_web_id

  def to_param
    web_id
  end

  def file_url
    "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{file.key}"
  end

  private

    def generate_template_text
      txt = whatsapp_template.text.gsub(/[^\\]\*/).with_index do |match, i|
        match.gsub(/\*/, content_params[i])
      end
      txt.gsub!(/\\\*/, '*')
      self.template_text = txt
    end

    def calculate_send_timezone
      time_zone = ActiveSupport::TimeZone.new(retailer.timezone.strip) if retailer.timezone.present?
      self.send_at_timezone = if time_zone
                                time_zone.local_to_utc(send_at)
                              else
                                time_zone = timezone.dup
                                send_at.change(offset: time_zone.insert(3, ':'))
                              end
    end
end
