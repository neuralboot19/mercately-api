FactoryBot.define do
  factory :template do
    title { 'Hay disponibilidad?' }
    answer { 'Sí, aún tenemos disponibilidad.' }
    retailer
  end
end
