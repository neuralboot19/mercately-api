namespace :retailers do
  task create_funnels: :environment do
    FunnelStep.all.find_each do |fs|
      fs.deals.each_with_index do |d, i|
        d.update_column(:position, i)
      end
    end
    Retailer.all.find_each(&:create_funnel_steps)
  end
end
