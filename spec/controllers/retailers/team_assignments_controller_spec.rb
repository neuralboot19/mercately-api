require 'rails_helper'

RSpec.describe 'TeamAssignmentsController', type: :request do
  let(:retailer) { create(:retailer) }
  let(:another_retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }

  before do
    allow_any_instance_of(Exponent::Push::Client).to receive(:send_messages).and_return(true)
  end

  describe 'GET #index' do
    context 'when the retailer is not logged in' do
      it 'redirects to login page' do
        get retailers_team_assignments_path(retailer)
        expect(response).to redirect_to('/login')
      end
    end

    context 'when the retailer is logged in' do
      before do
        create_list(:team_assignment, 3, retailer: retailer)
      end

      it 'responses ok' do
        sign_in retailer_user
        get retailers_team_assignments_path(retailer)
        expect(response).to have_http_status(:ok)

        retailer_teams = retailer.team_assignments.order(:name)
        expect(assigns(:teams)).to eq(retailer_teams)
      end
    end
  end

  describe 'GET #show' do
    before do
      sign_in retailer_user
    end

    context 'when the assignment team does not exist' do
      it 'responds 404' do
        pending 'Revisar por qué en Rspec no da 404'
        get retailers_team_assignment_path(retailer, 'anywebid')
        expect(response).to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the retailer in session is not the owner' do
      let(:team_assignment) { create(:team_assignment, retailer: another_retailer) }

      it 'responds 404' do
        pending 'Revisar por qué en Rspec no da 404'
        get retailers_team_assignment_path(retailer, team_assignment)
        expect(response).to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the retailer in session is the owner' do
      let(:team_assignment) { create(:team_assignment, retailer: retailer) }

      it 'responses ok' do
        get retailers_team_assignment_path(retailer, team_assignment)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET #new' do
    before do
      sign_in retailer_user
    end

    it 'responses ok' do
      get new_retailers_team_assignment_path(retailer)
      expect(response).to have_http_status(:ok)
      expect(assigns(:team_assignment)).to be_an_instance_of(TeamAssignment)
    end
  end

  describe 'POST #create' do
    before do
      sign_in retailer_user
    end

    context 'when the required data is supplied' do
      context 'when there is not another team with default assignment' do
        it 'creates a new assignment team' do
          expect do
            post retailers_team_assignments_path(retailer), params:
              {
                team_assignment:
                  {
                    name: 'Nuevo assignment team'
                  }
              }
          end.to change(TeamAssignment, :count).by(1)
        end
      end

      context 'when there is another team with default assignment' do
        let!(:team_default_assignment) { create(:team_assignment, :assigned_default, retailer: retailer) }

        it 'does not create a new assignment team' do
          expect do
            post retailers_team_assignments_path(retailer), params:
            {
              team_assignment:
                {
                  name: 'Nuevo assignment team',
                  default_assignment: true
                }
            }
          end.to change(TeamAssignment, :count).by(0)

          expect(assigns(:team_assignment).errors['base'][0]).to eq(
            'Ya existe un Equipo con la asignación por defecto activa'
          )
        end
      end
    end

    context 'when the required data is not supplied' do
      it 'does not create the assignment team' do
        expect do
          post retailers_team_assignments_path(retailer), params: { team_assignment: { name: '' } }
        end.to change(TeamAssignment, :count).by(0)

        expect(assigns(:team_assignment).errors['name'][0]).to eq('no puede estar vacío')
      end
    end
  end

  describe 'PUT #update' do
    before do
      sign_in retailer_user
    end

    context 'when the required data is supplied' do
      context 'when there is not another team with default assignment' do
        let(:team_assignment) { create(:team_assignment, retailer: retailer, name: 'Para editar') }

        it 'updates the assignment team' do
          expect(team_assignment.name).to eq('Para editar')

          put retailers_team_assignment_path(retailer, team_assignment), params:
            {
              team_assignment:
                {
                  name: 'Editar assignment team'
                }
            }

          expect(team_assignment.reload.name).to eq('Editar assignment team')
        end
      end

      context 'when there is another team with default assignment' do
        let!(:team_default_assignment) { create(:team_assignment, :assigned_default, retailer: retailer) }
        let(:team_assignment) { create(:team_assignment, retailer: retailer, name: 'Para editar') }

        it 'does not update the assignment team' do
          put retailers_team_assignment_path(retailer, team_assignment), params:
            {
              team_assignment:
                {
                  name: 'Editar assignment team',
                  default_assignment: true
                }
            }

          expect(team_assignment.reload.name).to eq('Para editar')
          expect(assigns(:team_assignment).errors['base'][0]).to eq(
            'Ya existe un Equipo con la asignación por defecto activa'
          )
        end
      end
    end

    context 'when the required data is not supplied' do
      let(:team_assignment) { create(:team_assignment, retailer: retailer, name: 'Para editar') }

      it 'does not update the assignment team' do
        put retailers_team_assignment_path(retailer, team_assignment), params:
          {
            team_assignment:
              {
                name: ''
              }
          }

        expect(assigns(:team_assignment).errors['name'][0]).to eq('no puede estar vacío')
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      sign_in retailer_user
    end

    context 'when the team has assigned chats' do
      let(:team_assignment) { create(:team_assignment, retailer: retailer) }
      let!(:agent_customer) do
        create(:agent_customer, retailer_user: retailer_user, team_assignment: team_assignment)
      end

      it 'does not delete the assignment team' do
        expect(TeamAssignment.count).to eq(1)

        delete retailers_team_assignment_path(retailer, team_assignment)

        expect(response).to have_http_status(:found)
        expect(TeamAssignment.count).to eq(1)
        expect(assigns(:team_assignment).errors['base'][0]).to eq(
          'Equipo no se puede eliminar, posee chats asignados'
        )
      end
    end

    context 'when the team does not have assigned chats' do
      let!(:team_assignment) { create(:team_assignment, retailer: retailer) }

      it 'deletes the assignment team' do
        expect(TeamAssignment.count).to eq(1)

        delete retailers_team_assignment_path(retailer, team_assignment)

        expect(response).to have_http_status(:found)
        expect(TeamAssignment.count).to eq(0)
      end
    end
  end
end
