class Funnel < ApplicationRecord
  belongs_to :retailer
  has_many :funnel_steps, dependent: :destroy

  validates :name, presence: true

  def update_column_order(columns)
    deleted = columns - funnel_steps.pluck(:web_id)
    columns -= deleted

    columns.each_with_index do |col, index|
      fs = funnel_steps.find_by(web_id: col)
      fs.position = index + 1
      fs.save
    end

    true
  end
end
