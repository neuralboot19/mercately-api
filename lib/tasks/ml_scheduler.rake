task :refresh_ml_access_code => :environment do
  puts "Updating ML Access Code"
  meli_infos_to_update = MeliInfo.joins(:retailer).where("meli_infos.updated_at < ? ", DateTime.current - 4.hours)
  meli_infos_to_update.each do |meli_info|
    retailer = meli_info.retailer
    MercadoLibre.new(retailer).refresh_access_token
  end
  puts "done."
end