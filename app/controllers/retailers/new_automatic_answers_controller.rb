class Retailers::NewAutomaticAnswersController < RetailersController
  include RenderReact

  react_actions! :index

  def index
  end
end
