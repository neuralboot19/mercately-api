require 'rails_helper'

RSpec.describe AgentTeam, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:retailer_user) }
    it { is_expected.to belong_to(:team_assignment) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:retailer_user_id).scoped_to(:team_assignment_id) }
  end

  describe '#free_spots_assignment' do
    let(:retailer) { create(:retailer) }
    let(:retailer_user) { create(:retailer_user, retailer: retailer) }
    let(:agent_team) { create(:agent_team, retailer_user: retailer_user, max_assignments: 5, assigned_amount: 3) }

    it 'returns the free spots for an agent on team' do
      expect(agent_team.free_spots_assignment).to eq(2)
    end
  end
end
