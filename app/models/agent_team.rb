class AgentTeam < ApplicationRecord
  belongs_to :retailer_user
  belongs_to :team_assignment

  validates :retailer_user_id, uniqueness: { scope: :team_assignment_id }

  before_create :assign_active

  scope :active_ones, -> { where(active: true) }

  def free_spots_assignment
    max_assignments - assigned_amount
  end

  private

    def assign_active
      self.active = retailer_user.active
    end
end
