namespace :opt_in do
  task number_to_use: :environment do
    Customer.where.not(number_to_use: nil).find_each do |c|
      c.send :opt_in_number_to_use
    end
  end
end
