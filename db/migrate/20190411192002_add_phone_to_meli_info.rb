class AddPhoneToMeliInfo < ActiveRecord::Migration[5.2]
  def change
    add_column :meli_infos, :phone, :string
  end
end
