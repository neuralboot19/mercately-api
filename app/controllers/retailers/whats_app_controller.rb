class Retailers::WhatsAppController < RetailersController
  layout 'chats/chat', only: :index

  # GET /messages
  def index
  end
end
