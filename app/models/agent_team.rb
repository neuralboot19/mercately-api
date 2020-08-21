class AgentTeam < ApplicationRecord
  belongs_to :retailer_user
  belongs_to :team_assignment

  validates :retailer_user_id, uniqueness: { scope: :team_assignment_id }

  scope :active_ones, -> { where(active: true) }

  def free_spots_assignment
    max_assignments - assigned_amount
  end
end
