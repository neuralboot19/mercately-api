class DemoRequestLead < ApplicationRecord
  validates_presence_of :name, :email, :company, :country, :phone, :message, :problem_to_resolve

  before_create :format_phone_number

  enum status: %i[pending scheduled done cancelled]

  def country_selected
    @country_selected ||= ISO3166::Country.new(country)
  end

  private

    def split_phone
      return unless phone.present?

      begin
        Phony.split(phone.gsub('+', ''))
      rescue Phony::SplittingError => e
        Rails.logger.error(e)
        SlackError.send_error(e)
        return
      end
    end

    def format_phone_number
      return unless phone.present? && country.present?

      country_code = country_selected&.country_code
      return unless country_code.present?

      splitted_phone = split_phone
      prefix = splitted_phone&.[](0)
      aux_phone = phone.gsub('+', '')

      self.phone = if prefix == country_code
                     "+#{aux_phone}"
                   else
                     "+#{country_code}#{aux_phone}"
                   end
    end
end
