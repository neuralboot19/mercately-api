namespace :retailers do
  task :most_used_tags_by_date, [:date] => :environment do |t, args|
    @start_date = Time.parse(Date.parse(args[:date]).strftime('%d/%m/%Y'))
    @end_date = @start_date.end_of_day
    @calculation_date = @end_date.to_date

    @new_records_most_used_tags = []

    Retailer.find_each do |retailer|
      customer_most_used_tags(retailer)
    end

    if @new_records_most_used_tags.any?
      RetailerMostUsedTag.create(@new_records_most_used_tags)
    end
  end

  task most_used_tags: :environment do
    @start_date = 1.day.ago.beginning_of_day
    @end_date = @start_date.end_of_day
    @calculation_date = @end_date.to_date

    @new_records_most_used_tags = []

    Retailer.find_each do |retailer|
      customer_most_used_tags(retailer)
    end

    if @new_records_most_used_tags.any?
      RetailerMostUsedTag.create(@new_records_most_used_tags)
    end
  end

  def customer_most_used_tags(retailer)
    retailer.customers.joins(:customer_tags)
    .select(:tag_id, :customer_id)
    .where("customer_tags.created_at": @start_date..@end_date)
    .group(:tag_id).count(:customer_id).each do |row|
      @new_records_most_used_tags.push({
        retailer_id: retailer.id,
        tag_id: row[0],
        amount_used: row[1],
        calculation_date: @calculation_date
      })
    end
  end
end