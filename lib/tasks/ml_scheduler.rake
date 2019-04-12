task refresh_ml_access_code: :environment do
  puts 'Updating ML Access Code'
  meli_retailers_to_update = MeliRetailer.joins(:retailer).where(
    'meli_retailers.updated_at < ? ',
    DateTime.current - 4.hours
  )
  meli_retailers_to_update.each do |meli_retailer|
    retailer = meli_retailer.retailer
    retailer.update_meli_access_token
    retailer.update_meli_retailer
  end
  puts 'done.'
end
