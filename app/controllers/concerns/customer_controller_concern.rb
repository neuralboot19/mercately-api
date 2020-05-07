module CustomerControllerConcern
  extend ActiveSupport::Concern

  def edit_setup
    if @customer.phone.present?
      if @customer.country_id.present?
        @customer.phone = @customer.phone.gsub("+#{@customer.country.country_code}", '')
      else
        parse_phone = Phonelib.parse(@customer.phone)
        if parse_phone&.country
          @customer.country_id = parse_phone.country
          @customer.phone = @customer.phone.gsub("+#{@customer.country.country_code}", '')
        end
      end
    end
  end
end
