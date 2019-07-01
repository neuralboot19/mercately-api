class CategoriesController < ApplicationController
  def roots
    @roots = Category.roots
    render json: { roots: @roots }
  end

  def childs
    category = Category.find(params[:id])
    @child_categories = category.children
    render json: { child_categories: @child_categories, template: category.clean_template_variations }
  end
end
