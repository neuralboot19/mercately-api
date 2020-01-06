class CustomersChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_retailer_user.retailer
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
