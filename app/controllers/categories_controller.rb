class CategoriesController < ApplicationController
  def roots
    @roots = Category.roots
    render json: { roots: @roots }
  end

  def childs
    @child_categories = Category.find(params[:id]).children
    render json: { child_categories: @child_categories }
  end
end
