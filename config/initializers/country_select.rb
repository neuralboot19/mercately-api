CountrySelect::FORMATS[:with_country_code] = lambda do |country|
  "#{country.translations[I18n.locale.to_s] || country.name} (+#{country.country_code})"
end
