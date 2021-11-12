class FunnelStep < ApplicationRecord
  include WebIdGenerateableConcern
  default_scope { order(:position) }

  belongs_to :funnel
  has_many :deals, -> { order(:position) }, dependent: :destroy

  validates :name, presence: true

  before_create :position!
  before_destroy :arrange_positions
  after_create :generate_funnel_web_id

  def currency_symbol
    funnel.retailer.currency_symbol
  end

  def total
    '%.2f' % deals.sum(:amount)
  end

  def deals_count
    deals.count
  end

  private

    def position!
      max_step = funnel.funnel_steps.maximum(:position)
      self.position = max_step ? max_step + 1 : 1
    end

    def arrange_positions
      funnel.funnel_steps.each_with_index do |step, index|
        step.update_columns(position: index + 1)
      end
    end
end
