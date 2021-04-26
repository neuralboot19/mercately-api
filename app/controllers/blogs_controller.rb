class BlogsController < ApplicationController
  layout 'blog/blog'
  before_action :set_prismic_variables
  before_action :track_ahoy_visit, only: :index

  def index
    api = Prismic.api(@url, @token)
    response = api.query(Prismic::Predicates.at("document.type", "blogentry"),
       { "pageSize" => 100, "orderings" => "[document.first_publication_date desc]"})
    @documents = response.results
  end

  def show
    api = Prismic.api(@url, @token)
    @document = api.getByUID("blogentry", params[:id])

    response = api.query([
      Prismic::Predicates.at("document.type", "blogentry"),
      Prismic::Predicates.at("my.blogentry.category", @document.fragments['category']&.value)],
      { "pageSize" => 6, "orderings" => "[document.first_publication_date desc]"}
    )
    @documents = response.results
  end

  def innovation
    api = Prismic.api(@url, @token)
    response = api.query(Prismic::Predicates.at("document.type", "funcionalidades"),
       { "pageSize" => 100, "orderings" => "[document.first_publication_date desc]"})
    @documents = response.results
  end

  def innovation_content

    api = Prismic.api(@url, @token)
    @document = api.getByUID("funcionalidades", params[:id])

    response = api.query([
      Prismic::Predicates.at("document.type", "funcionalidades"),
      Prismic::Predicates.at("my.funcionalidades.category", @document.fragments['category']&.value)],
      { "pageSize" => 6, "orderings" => "[document.first_publication_date desc]"}
    )
    @documents = response.results
  end

  def category
    api = Prismic.api(@url, @token)
    category_id = params[:id]

    response = api.query([
      Prismic::Predicates.at("document.type", "blogentry"),
      Prismic::Predicates.at("my.blogentry.category", category_id.capitalize)],
      { "pageSize" => 100, "orderings" => "[document.first_publication_date desc]"}
    )

    @documents = response.results
  end

  def tag
    api = Prismic.api(@url, @token)
    tag_id = params[:id]

    response = api.query(
      Prismic::Predicates.any("document.tags", [tag_id, tag_id&.capitalize])
    )

    @documents = response.results
  end

  private

  def set_prismic_variables
    @url = ENV['PRISMIC_URL']
    @token = ENV['PRISMIC_TOKEN']
  end
end
