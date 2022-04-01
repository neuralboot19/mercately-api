require 'rails_helper'

RSpec.describe TeamAssignment, type: :model do
  let(:retailer) { create(:retailer) }
  subject(:team_assignment) { create(:team_assignment, retailer: retailer) }

  before do
    allow_any_instance_of(Exponent::Push::Client).to receive(:send_messages).and_return(true)
  end

  describe 'associations' do
    it { is_expected.to belong_to(:retailer) }
    it { is_expected.to have_many(:agent_teams).dependent(:destroy) }
    it { is_expected.to have_many(:retailer_users) }
    it { is_expected.to have_many(:agent_customers) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#to_param' do
    it 'returns the team web id' do
      expect(team_assignment.to_param).to eq(team_assignment.web_id)
    end
  end

  describe '#default_activation_unique' do
    context 'when it is not a team with default assignment' do
      it 'returns nil' do
        expect(team_assignment.send(:default_activation_unique)).to be_nil
      end
    end

    context 'when there is not other team with default assignment' do
      it 'saves the team' do
        expect {
          create(:team_assignment, :assigned_default, retailer: retailer)
        }.to change(TeamAssignment, :count).by(1)
      end
    end

    context 'when there is other team with default assignment' do
      let!(:default_team) { create(:team_assignment, :assigned_default, retailer: retailer) }

      it 'does not save the team' do
        team_assignment.default_assignment = true
        team_assignment.save

        expect(team_assignment.errors['base'][0]).to eq('Ya existe un Equipo con la asignación por defecto activa')
      end
    end
  end

  describe '#check_destroy_requirements' do
    context 'when the team has agent customers associated' do
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }
      let!(:agent_customer) do
        create(:agent_customer, team_assignment: team_assignment, retailer_user: retailer_user)
      end

      it 'does not destroy the team' do
        expect { team_assignment.send(:check_destroy_requirements) }.to throw_symbol(:abort)
        expect(team_assignment.errors['base'][0]).to eq('Equipo no se puede eliminar, posee chats asignados')
      end
    end

    context 'when the team does not have agent customers associated' do
      it 'does destroy the team' do
        team_assignment.send(:check_destroy_requirements)
        expect(team_assignment.errors['base']).to be_empty
      end
    end
  end

  describe '#assign_agent' do
    let(:agent1) { create(:retailer_user, retailer: retailer) }
    let(:agent2) { create(:retailer_user, retailer: retailer) }
    let(:agent3) { create(:retailer_user, retailer: retailer) }
    let(:agent_team1) { create(:agent_team, team_assignment: team_assignment, retailer_user: agent1) }
    let(:agent_team2) { create(:agent_team, team_assignment: team_assignment, retailer_user: agent2) }
    let(:agent_team3) { create(:agent_team, team_assignment: team_assignment, retailer_user: agent3) }
    let(:customer1) { create(:customer, retailer: retailer) }
    let(:customer2) { create(:customer, retailer: retailer) }
    let(:customer3) { create(:customer, retailer: retailer) }

    it 'assigns one chat to every agent team' do
      allow_any_instance_of(Shared::AutomaticAssignments).to receive(:notify_agents).and_return(true)
      agent_team1
      agent_team2
      agent_team3

      arr = [customer1, customer2, customer3]
      Parallel.each(arr, in_threads: 3) do |c|
        team_assignment.assign_agent(c)
      end

      expect(agent_team1.reload.assigned_amount).to eq(1)
      expect(agent_team2.reload.assigned_amount).to eq(1)
      expect(agent_team3.reload.assigned_amount).to eq(1)
      expect(team_assignment.reload.last_assigned).to eq(agent_team3.id)
    end
  end
end
