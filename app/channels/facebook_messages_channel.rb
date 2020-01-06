class FacebookMessagesChannel < ApplicationCable::Channel
  def subscribed
    conversation = Customer.find(params[:id])
    stream_for conversation
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
