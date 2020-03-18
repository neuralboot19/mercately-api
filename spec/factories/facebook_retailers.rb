FactoryBot.define do
  factory :facebook_retailer do
    retailer
    uid { Faker::IDNumber.valid }
    access_token { 'EAACx6JZCO4HYBAKlbKurdBSYxgrnaZAbsxZCwA7CM8YUY8a28wD3ag5nxWfOELceZBHbZCbvuq2n5ZAs0aVA4TEAF7SwCUujvrfs1KI2VaLzruW91MCZCyXjPLuz2osZAZBPBApryz2LRVWC0DMYZCDLGrZAo9IkuhKHnBanzooxd6mrgZDZD' }
  end
end
