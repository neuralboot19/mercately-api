class TopUp < ApplicationRecord
  belongs_to :retailer

  after_create :update_ws_balance

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 25.0 }
  validates :retailer, presence: true

  private

    def update_ws_balance
      retailer.ws_balance += amount
      retailer.ws_next_notification_balance = 1.5
      retailer.save
    end
end
