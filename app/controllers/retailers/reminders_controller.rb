class Retailers::RemindersController < RetailersController
  def index
    @reminders = current_retailer.reminders.ransack(params[:q]).order('created_at desc').page(params[:page])
  end
end
