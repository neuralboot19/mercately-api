class WhatsappTemplate < ApplicationRecord
  belongs_to :retailer

  enum status: %i[inactive active]
  enum template_type: %i[text image file]

  def clean_template
    text.gsub('\\*', '*')
  end
end
