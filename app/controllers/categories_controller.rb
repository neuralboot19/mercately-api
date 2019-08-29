class CategoriesController < ApplicationController
  def roots
    @roots = Category.roots.active_categories
    render json: { roots: @roots }
  end

  def childs
    category = Category.active_categories.find(params[:id])
    @child_categories = category.children.active_categories
    render json: {
      child_categories: @child_categories,
      template: category.clean_template_variations
    }
  end
end
