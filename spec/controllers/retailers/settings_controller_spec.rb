require 'rails_helper'

RSpec.describe Retailers::SettingsController, type: :controller do
  let(:retailer_user) { create(:retailer_user, :with_retailer, first_name: '', last_name: '' ) }

  before do
    sign_in retailer_user
  end

  describe '#team' do
    it 'redirects to root if current_retailer_user is not admin' do
      retailer_user.retailer_admin = false
      retailer_user.save!

      get :team, params: { slug: retailer_user.retailer.slug }
      expect(response).to redirect_to(root_path(retailer_user.retailer.slug))
    end

    it 'will set the right team members and a new instance of RetailerUser' do
      create(:retailer_user, retailer: retailer_user.retailer, first_name: '', last_name: '' )

      get :team, params: { slug: retailer_user.retailer.slug }
      right_retailers = RetailerUser.all.reject { |u| u == retailer_user }

      expect(assigns(:team)).to eq(right_retailers)
      expect(assigns(:user)).to be_an_instance_of(RetailerUser)
    end
  end

  describe '#invite_team_member' do
    it 'creates a new retailer user as agent with first name and last name' do
      agent_invited = {
        email: 'test@email.com',
        first_name: 'John',
        last_name: 'Wick'
      }

      expect {
        post :invite_team_member, params: { slug: retailer_user.retailer.slug, retailer_user: agent_invited }
      }.to change { RetailerUser.count }.by(1)
      expect(RetailerUser.find_by_email('test@email.com').retailer_admin).to be(nil)
    end

    it 'creates a new retailer user as admin with first name and last name' do
      admin_invited = {
        email: 'test@email.com',
        first_name: 'John',
        last_name: 'Wick',
        retailer_admin: true
      }

      expect {
        post :invite_team_member, params: { slug: retailer_user.retailer.slug, retailer_user: admin_invited }
      }.to change { RetailerUser.count }.by(1)
      expect(RetailerUser.find_by_email('test@email.com').retailer_admin).to be(true)
    end

    it 'shows a notice with error if an exception occurs' do
      allow_any_instance_of(RetailerUser).to receive(:invite!).and_return(Exception)

      agent_invited = {
        email: 'test@email.com',
        first_name: 'John',
        last_name: 'Wick'
      }
      post :invite_team_member, params: { slug: retailer_user.retailer.slug, retailer_user: agent_invited }

      expect(response).to redirect_to(retailers_dashboard_path(retailer_user.retailer.slug))
      expect(flash[:notice]).to be_present
      expect(flash[:notice]).to match(/Error al invitar usuario..*/)
    end
  end

  describe '#set_admin_team_member' do
    it 'set the member as admin' do
      member = create(:retailer_user, retailer: retailer_user.retailer, retailer_admin: false )

      post :set_admin_team_member, params: { slug: retailer_user.retailer.slug, user: member.id }
      expect(member.reload.retailer_admin).to eq(true)
    end

    it 'redirects to dashboard if an exception occurs' do
      allow_any_instance_of(RetailerUser).to receive(:update_attribute).and_return(false)
      member = create(:retailer_user, retailer: retailer_user.retailer, retailer_admin: false )

      post :set_admin_team_member, params: { slug: retailer_user.retailer.slug, user: member.id }

      expect(response).to redirect_to(retailers_dashboard_path(retailer_user.retailer.slug))
      expect(flash[:notice]).to be_present
      expect(flash[:notice]).to match(/Error al actualizar usuario..*/)
    end
  end

  describe '#set_agent_team_member' do
    it 'set the admin as agent' do
      member = create(:retailer_user, retailer: retailer_user.retailer, retailer_admin: true )

      post :set_agent_team_member, params: { slug: retailer_user.retailer.slug, user: member.id }
      expect(member.reload.retailer_admin).to eq(false)
    end

    it 'redirects to dashboard if an exception occurs' do
      member = create(:retailer_user, retailer: retailer_user.retailer, retailer_admin: true )
      allow_any_instance_of(RetailerUser).to receive(:update_attribute).and_return(false)

      post :set_agent_team_member, params: { slug: retailer_user.retailer.slug, user: member.id }

      expect(response).to redirect_to(retailers_dashboard_path(retailer_user.retailer.slug))
      expect(flash[:notice]).to be_present
      expect(flash[:notice]).to match(/Error al actualizar usuario..*/)
    end
  end

  describe '#reinvite_team_member' do
    it 'reinvites the member' do
      days_ago = Time.now - 2.days
      member = create(:retailer_user, retailer: retailer_user.retailer, invitation_sent_at: days_ago )

      post :reinvite_team_member, params: { slug: retailer_user.retailer.slug, user: member.id }
      expect(member.reload.invitation_sent_at).to_not eq(days_ago)
    end

    it 'redirects to dashboard if not member found' do
      post :reinvite_team_member, params: { slug: retailer_user.retailer.slug, user: 1 }

      expect(response).to redirect_to(retailers_dashboard_path(retailer_user.retailer.slug))
      expect(flash[:notice]).to be_present
      expect(flash[:notice]).to match(/Error al invitar usuario..*/)
    end
  end

  describe '#remove_team_member' do
    it 'removes member from team' do
      member = create(:retailer_user, retailer: retailer_user.retailer, retailer_admin: false )

      post :remove_team_member, params: { slug: retailer_user.retailer.slug, user: member.id }
      expect(member.reload.removed_from_team).to eq(true)
    end

    it 'redirects to dashboard if an exception occurs' do
      allow_any_instance_of(RetailerUser).to receive(:update_column).and_return(false)
      member = create(:retailer_user, retailer: retailer_user.retailer, retailer_admin: false )

      post :remove_team_member, params: { slug: retailer_user.retailer.slug, user: member.id }

      expect(response).to redirect_to(retailers_dashboard_path(retailer_user.retailer.slug))
      expect(flash[:notice]).to be_present
      expect(flash[:notice]).to match(/Error al remover usuario..*/)
    end
  end

  describe '#reactive_team_member' do
    it 'reactive member from team' do
      member = create(:retailer_user, retailer: retailer_user.retailer, retailer_admin: false )

      post :reactive_team_member, params: { slug: retailer_user.retailer.slug, user: member.id }
      expect(member.reload.removed_from_team).to eq(false)
    end

    it 'redirects to dashboard if an exception occurs' do
      allow_any_instance_of(RetailerUser).to receive(:update_column).and_return(false)
      member = create(:retailer_user, retailer: retailer_user.retailer, retailer_admin: false )

      post :reactive_team_member, params: { slug: retailer_user.retailer.slug, user: member.id }

      expect(response).to redirect_to(retailers_dashboard_path(retailer_user.retailer.slug))
      expect(flash[:notice]).to be_present
      expect(flash[:notice]).to match(/Error al reactivar usuario..*/)
    end
  end
end
