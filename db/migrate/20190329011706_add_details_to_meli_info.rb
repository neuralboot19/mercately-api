class AddDetailsToMeliInfo < ActiveRecord::Migration[5.2]
  def change
    add_column :meli_infos, :nickname, :string
    add_column :meli_infos, :email, :string
    add_column :meli_infos, :points, :integer
    add_column :meli_infos, :link, :string
    add_column :meli_infos, :seller_experience, :string
    add_column :meli_infos, :seller_reputation_level_id, :string
    add_column :meli_infos, :transactions_canceled, :integer
    add_column :meli_infos, :transactions_completed, :integer
    add_column :meli_infos, :ratings_negative, :integer
    add_column :meli_infos, :ratings_neutral, :integer
    add_column :meli_infos, :ratings_positive, :integer
    add_column :meli_infos, :ratings_total, :integer
  end
end
