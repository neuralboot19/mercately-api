class CategoriesController < ApplicationController
  def roots
    @roots = Category.active.roots
    render json: { roots: @roots }
  end

  def childs
    category = Category.active.find(params[:id])
    @child_categories = category.children.active
    render json: {
      child_categories: @child_categories,
      template: category.clean_template_variations
    }
  end
end
