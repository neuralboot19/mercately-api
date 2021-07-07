FactoryBot.define do
  factory :gs_template do
    retailer
    status { 0 }
    label { 'label_formatted' }
    key { 0 }
    category { 'ACCOUNT_UPDATE' }
    text { 'My Text with var {{1}}' }
    example { 'My Text with var [Variable text]' }
    language { 'spanish' }
  end
end
