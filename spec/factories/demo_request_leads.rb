FactoryBot.define do
  factory :demo_request_lead do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    company { Faker::Company.name }
    employee_quantity { 10 }
    country { 'EC' }
    phone { Faker::PhoneNumber.cell_phone }
    message { Faker::Lorem.paragraph }
    problem_to_resolve { 'Tener chatbots en Whatsapp' }
  end
end
