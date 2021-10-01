class WhatsappLog < ApplicationRecord
  belongs_to :retailer
  belongs_to :gupshup_whatsapp_message, required: false
end
