class BlogsController < ApplicationController
  layout 'blog/blog'
  before_action :set_prismic_variables

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
