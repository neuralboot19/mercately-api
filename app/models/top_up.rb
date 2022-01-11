class TopUp < ApplicationRecord
  belongs_to :retailer

  validates :amount, presence: true
  validates :retailer, presence: true

  after_create :update_ws_balance

  private

    def update_ws_balance
      retailer.ws_balance += amount
      retailer.ws_next_notification_balance = 1.5
      retailer.save!
    end
end
