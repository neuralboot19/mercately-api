class WhatsappTemplate < ApplicationRecord
  belongs_to :retailer

  enum status: %i[inactive active]

  def clean_template
    text.gsub('\\*', '*')
  end
end
