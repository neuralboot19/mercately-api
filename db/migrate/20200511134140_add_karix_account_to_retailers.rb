class AddKarixAccountToRetailers < ActiveRecord::Migration[5.2]
  def up
    add_column :retailers, :karix_account_uid, :string
    add_column :retailers, :karix_account_token, :string

    if ENV['ENVIRONMENT'] == 'production'
      mercately_test = Retailer.find(6)
      mercately_test.update_columns(karix_account_uid: '10d2376a-f386-4c52-9878-a7e7faee95bb',
        karix_account_token: '35f3bdd8-3fac-40b3-a58a-799d32982038')

      peque_ayuda = Retailer.find(306)
      peque_ayuda.update_columns(karix_account_uid: 'da106802-15cb-4cdd-957e-eb5929acfd4f',
        karix_account_token: 'a4586c05-10ce-468b-8bf9-4dbfd0214ed9')

      cadeco = Retailer.find(160)
      cadeco.update_columns(karix_account_uid: 'e0a833b2-ad19-4d9d-8781-053e0ecefcb6',
        karix_account_token: 'e03254cd-d3f7-435e-8c2e-59cddd1dcb80')

      cuzy = Retailer.find(223)
      cuzy.update_columns(karix_account_uid: '10d2376a-f386-4c52-9878-a7e7faee95bb',
        karix_account_token: '35f3bdd8-3fac-40b3-a58a-799d32982038')
    end
  end

  def down
    remove_column :retailers, :karix_account_uid, :string
    remove_column :retailers, :karix_account_token, :string
  end
end
