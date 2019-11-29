module DashboardHelper
  def retailer_products(retailer)
    q = { s: 'sort_by_earned desc' }
    current_retailer.products.ransack(q).result.limit(10).with_attached_images
  end

  def products_by_category(retailer)
    category_ids = retailer.products.distinct(:category_id).pluck(:category_id)
    categories = Category.where(id: category_ids)
    output = []

    categories.each do |cat|
      output << {
        name: cat.name,
        total_products: cat.total_products(retailer),
        total_sold: cat.total_products_sold(retailer),
        earning: cat.earnings(retailer)
      }
    end

    output.sort { |a, b| b[:earning] <=> a[:earning] }
  end

  def best_clients(retailer)
    q = { s: 'sort_by_total desc' }
    retailer.customers.ransack(q).result.limit(10)
  end
end
