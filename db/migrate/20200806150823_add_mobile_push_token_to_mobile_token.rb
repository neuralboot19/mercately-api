class AddMobilePushTokenToMobileToken < ActiveRecord::Migration[5.2]
  def change
    add_column :mobile_tokens, :mobile_push_token, :string
  end
end
