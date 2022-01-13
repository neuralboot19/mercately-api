class RetailerUserNotification < ApplicationRecord
  belongs_to :retailer_user
  belongs_to :notification
end
