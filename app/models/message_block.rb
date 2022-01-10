class MessageBlock < ApplicationRecord
  belongs_to :retailer

  validates_presence_of :phone, :sent_date
end
