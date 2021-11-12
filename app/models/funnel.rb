class Funnel < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  has_many :funnel_steps, dependent: :destroy

  validates :name, presence: true

  after_create :generate_web_id

  def to_param
    web_id
  end

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
