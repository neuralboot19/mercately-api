namespace :retailers do
  task create_funnels: :environment do
    FunnelStep.all.find_each do |fs|
      fs.deals.each_with_index do |d, i|
        d.update_column(:position, i)
      end
    end
    Retailer.all.find_each(&:create_funnel_steps)
  end

  task set_last_card_main: :environment do
    Retailer.joins(:payment_methods).find_each do |r|
      r.payment_methods.last.main!
    end
  end
end
