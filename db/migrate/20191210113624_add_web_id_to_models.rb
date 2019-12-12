class AddWebIdToModels < ActiveRecord::Migration[5.2]
  def up
    add_column :customers, :web_id, :string
    add_column :products, :web_id, :string
    add_column :orders, :web_id, :string
    add_column :questions, :web_id, :string
    add_column :templates, :web_id, :string

    letters = ('a'..'z').to_a
    Customer.all.each do |c|
      c.update_column(:web_id, c.retailer.id.to_s + letters.sample(5).join + c.id.to_s)
    end

    Product.all.each do |pro|
      pro.update_column(:web_id, pro.retailer.id.to_s + letters.sample(5).join + pro.id.to_s)
    end

    Order.all.each do |ord|
      ord.update_column(:web_id, ord.retailer.id.to_s + letters.sample(5).join + ord.id.to_s)
    end

    Question.all.each do |q|
      q.update_column(:web_id, q.retailer.id.to_s + letters.sample(5).join + q.id.to_s)
    end

    Message.all.each do |m|
      m.update_column(:web_id, m.retailer.id.to_s + letters.sample(5).join + m.id.to_s)
    end

    Template.all.each do |t|
      t.update_column(:web_id, t.retailer.id.to_s + letters.sample(5).join + t.id.to_s)
    end
  end

  def down
    remove_column :customers, :web_id, :string
    remove_column :products, :web_id, :string
    remove_column :orders, :web_id, :string
    remove_column :questions, :web_id, :string
    remove_column :templates, :web_id, :string
  end
end
