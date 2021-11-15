# frozen_string_literal: true

class Campaign < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :whatsapp_template
  belongs_to :contact_group
  belongs_to :retailer
  has_many :gupshup_whatsapp_messages
  has_many :karix_whatsapp_messages
  has_one_attached :file

  validates_presence_of :name, :send_at

  before_create :set_timezone
  before_create :generate_template_text
  after_create :generate_web_id
  after_update :success, if: :sent?
  after_update :send_reason, if: :failed?

  enum status: %i[pending sent cancelled failed processing]

  attr_accessor :timezone

  def to_param
    web_id
  end

  def estimated_cost
    contact_group.customers.sum(:ws_notification_cost)
  end

  def cost
    return 0 unless sent?

    gupshup_whatsapp_messages
      .includes(:customer)
      .where.not(status: :error)
      .sum('customers.ws_notification_cost')
  end

  def customer_details_template(customer)
    template_text.gsub(/{{\w*}}/) do |match|
      vars = match.gsub(/\w+/) do |method|
        if method.in?(Customer.public_fields)
          customer.send(method)&.presence || ' '
        else
          crf = retailer.customer_related_fields.find_by(identifier: method)
          next ' ' if crf.nil?

          crf.customer_related_data.find_by(customer: customer)&.data || ' '
        end
      end

      vars.gsub!(/{|}/, '')
    end
  end

  def customer_content_params(customer)
    return [] unless content_params.present?

    replaced_params = []
    content_params.each do |cp|
      replaced_params << cp.gsub(/{{\w*}}/) do |match|
        vars = match.gsub(/\w+/) do |method|
          if method.in?(Customer.public_fields)
            customer.send(method)&.presence || ' '
          else
            crf = retailer.customer_related_fields.find_by(identifier: method)
            next ' ' if crf.nil?

            crf.customer_related_data.find_by(customer: customer)&.data || ' '
          end
        end

        vars.gsub!(/{|}/, '')
      end
    end

    replaced_params
  end

  def time_with_zone
    if retailer.timezone.present?
      ActiveSupport::TimeZone.new(retailer.timezone).utc_to_local(send_at)
    else
      send_at.localtime
    end
  end

  def file_url
    if file.content_type.include?('video/')
      "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/video/upload/#{file.key}"
    else
      "https://res.cloudinary.com/#{ENV['CLOUDINARY_CLOUD_NAME']}/image/upload/#{file.key}"
    end
  end

  private

    def generate_template_text
      txt = whatsapp_template.text.gsub(/[^\\]\*/).with_index do |match, i|
        match.gsub(/\*/, content_params[i])
      end
      txt.gsub!(/\\\*/, '*')
      self.template_text = txt
    end

    def success
      RetailerUser.active_admins(retailer.id).each do |ru|
        CampaignMailer.success(self, ru).deliver_now
      end
    end

    # "reason" es simplemente un campo en la db con el nombre del método a ejecutar
    def send_reason
      send reason
    end

    def service_down
      RetailerUser.active_admins(retailer.id).each do |ru|
        CampaignMailer.service_down(self, ru).deliver_now
      end
    end

    def insufficient_balance
      RetailerUser.active_admins(retailer.id).each do |ru|
        CampaignMailer.insufficient_balance(self, ru).deliver_now
      end
    end

    def set_timezone
      time_zone = ActiveSupport::TimeZone.new(retailer.timezone.strip) if retailer.timezone.present?
      self.send_at = if time_zone
                       time_zone.local_to_utc(send_at)
                     else
                       send_at.change(offset: timezone&.insert(3, ':'))
                     end
    end
end
