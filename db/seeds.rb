# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if Rails.env.development?
  # AdminUser.create(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
  # r_user = FactoryBot.create(:retailer_user, :with_retailer, email: 'retailer_user@example.com')
  (1..50).each do |i|
    customer = Customer.create(phone: '+123456789' + i.to_s + 'fake', retailer_id: 9)

    (1..200).each do |index|
      KarixWhatsappMessage.create(uid: Time.now.to_i.to_s + index.to_s, retailer_id: 9, customer_id:
        customer.id, content_type: 'text', content_text: 'Mensajes para testing.', direction:
        index.even? ? 'outbound' : 'inbound', status: 'sent', created_time: Time.now, sent_time:
        Time.now, source: index.even? ? '+13253077759' : customer.phone, destination:
        index.even? ? customer.phone : '+13253077759', message_type: 'conversation')
    end
  end
end
