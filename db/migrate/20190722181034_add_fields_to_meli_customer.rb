class AddFieldsToMeliCustomer < ActiveRecord::Migration[5.2]
  def up
    add_column :meli_customers, :buyer_canceled_transactions, :integer
    add_column :meli_customers, :buyer_completed_transactions, :integer
    add_column :meli_customers, :buyer_canceled_paid_transactions, :integer
    add_column :meli_customers, :buyer_unrated_paid_transactions, :integer
    add_column :meli_customers, :buyer_unrated_total_transactions, :integer
    add_column :meli_customers, :buyer_not_yet_rated_paid_transactions, :integer
    add_column :meli_customers, :buyer_not_yet_rated_total_transactions, :integer
    add_column :meli_customers, :meli_registration_date, :datetime
    add_column :meli_customers, :phone_area, :string
    add_column :meli_customers, :phone_verified, :boolean
  end

  def down
    remove_column :meli_customers, :buyer_canceled_transactions, :integer
    remove_column :meli_customers, :buyer_completed_transactions, :integer
    remove_column :meli_customers, :buyer_canceled_paid_transactions, :integer
    remove_column :meli_customers, :buyer_unrated_paid_transactions, :integer
    remove_column :meli_customers, :buyer_unrated_total_transactions, :integer
    remove_column :meli_customers, :buyer_not_yet_rated_paid_transactions, :integer
    remove_column :meli_customers, :buyer_not_yet_rated_total_transactions, :integer
    remove_column :meli_customers, :meli_registration_date, :datetime
    remove_column :meli_customers, :phone_area, :string
    remove_column :meli_customers, :phone_verified, :boolean
  end
end
