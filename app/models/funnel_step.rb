class FunnelStep < ApplicationRecord
  include WebIdGenerateableConcern
  default_scope { order(:position) }

  belongs_to :funnel
  has_many :deals, dependent: :destroy

  before_destroy :arrange_positions
  before_create :get_position
  after_create :generate_funnel_web_id

  validates :name, presence: true

  private

    def get_position
      max_step = funnel.funnel_steps.pluck(:position).compact.max
      self.position = max_step ? max_step + 1 : 1
    end

    def arrange_positions
      funnel.funnel_steps.each_with_index do |step, index|
        step.update_columns(position: index + 1)
      end
    end
end
