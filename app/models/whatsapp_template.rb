class WhatsappTemplate < ApplicationRecord
  belongs_to :retailer

  enum status: %i[inactive active]
end
