module PhoneNumberConcern
  extend ActiveSupport::Concern

  def phone_number(with_plus_sign = true)
    if self.class.name == 'Retailer'
      return unless gupshup_phone_number.present? || karix_whatsapp_phone.present?
      str = gupshup_phone_number || karix_whatsapp_phone
    elsif self.class.name == 'Customer'
      return unless phone.present?
      str = phone
    end

    with_plus_sign ? str : str.gsub('+', '')
  end
end
