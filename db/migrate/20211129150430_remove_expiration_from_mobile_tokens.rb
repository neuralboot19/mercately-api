class RemoveExpirationFromMobileTokens < ActiveRecord::Migration[5.2]
  def change
    remove_column :mobile_tokens, :expiration, :datetime
  end
end
