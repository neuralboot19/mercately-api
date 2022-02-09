class Retailers::NewStatsController < RetailersController
  include RenderReact

  react_actions! :index

  def index
  end
end