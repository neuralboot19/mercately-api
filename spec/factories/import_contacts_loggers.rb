FactoryBot.define do
  factory :import_contacts_logger do
    retailer
    retailer_user
    original_file_name { 'Test file.xlsx' }
  end
end
