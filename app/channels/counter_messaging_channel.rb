class CounterMessagingChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_retailer_user
  end
end
