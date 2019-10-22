class AddOnboardingStatusToRetailerUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :retailer_users, :onboarding_status, :jsonb, default: { step: 0, skipped: false, completed: false }
  end
end
