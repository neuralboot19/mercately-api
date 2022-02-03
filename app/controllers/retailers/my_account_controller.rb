class Retailers::MyAccountController < RetailersController
  layout 'chats/chat', only: :index

  def index
  end
end
