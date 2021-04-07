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

  def phone_number_to_use(with_plus_sign = true)
    return unless number_to_use.present?

    with_plus_sign ? number_to_use : number_to_use.gsub('+', '')
  end
end
