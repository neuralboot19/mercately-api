class BlogsController < ApplicationController
  layout 'blog/blog'
  before_action :set_prismic_variables
  before_action :track_ahoy_visit, only: :index

  def index
    api = Prismic.api(@url, @token)
    response = api.query(Prismic::Predicates.at("document.type", "blogentry"))
    @documents = response.results
  end

  def show
    api = Prismic.api(@url, @token)
    @document = api.getByUID("blogentry", params[:id])
  end

  private

  def set_prismic_variables
    @url = ENV['PRISMIC_URL']
    @token = ENV['PRISMIC_TOKEN']
  end
end
