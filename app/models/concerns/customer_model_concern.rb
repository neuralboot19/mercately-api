module CustomerModelConcern
  extend ActiveSupport::Concern

  def phone_number(with_plus_sign = true)
    return unless phone.present?

    with_plus_sign ? phone : phone.gsub('+', '')
  end
end
