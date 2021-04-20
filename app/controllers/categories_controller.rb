class CategoriesController < ApplicationController
  def roots
    ml_site = current_retailer_user.retailer.ml_site
    @roots = Category.active.roots.where("meli_id LIKE '#{ml_site}%'").order(:name)
    render json: { roots: @roots }
  end

  def childs
    category = Category.active.find(params[:id])
    @child_categories = category.children.active.order(:name)
    render json: {
      child_categories: @child_categories,
      template: category.clean_template_variations
    }
  end
end
