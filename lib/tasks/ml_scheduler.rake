task refresh_ml_access_code: :environment do
  puts 'Updating ML Access Code'
  meli_retailers_to_update = MeliRetailer.joins(:retailer).where(
    '((meli_retailers.meli_token_updated_at IS NULL OR meli_retailers.meli_token_updated_at < ?)
    AND meli_retailers.refresh_token IS NOT NULL)
    OR ((meli_retailers.meli_info_updated_at IS NULL OR meli_retailers.meli_info_updated_at < ?)
    AND meli_retailers.access_token IS NOT NULL AND meli_retailers.meli_user_active = ?)',
    DateTime.current - 4.hours, DateTime.current - 7.days, true
  )
  puts "Updating ML Access Code #{meli_retailers_to_update.size}"
  meli_retailers_to_update.each do |meli_retailer|
    retailer = meli_retailer.retailer
    retailer.update_meli_access_token
    meli_retailer.save
  end
  puts 'done.'
end
