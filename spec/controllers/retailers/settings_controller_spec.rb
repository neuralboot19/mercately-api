require 'rails_helper'

RSpec.describe Retailers::SettingsController, type: :controller do
  let(:retailer_user) { create(:retailer_user, first_name: '', last_name: '' ) }

  before do
    sign_in retailer_user
  end

  describe '#invite_team_member' do
    it 'creates a new retailer user with first name and last name' do
      agent_invited = {
        email: 'test@email.com',
        first_name: 'John',
        last_name: 'Wick'
      }

      expect {
        post :invite_team_member, params: { slug: retailer_user.retailer.slug, retailer_user: agent_invited }
      }.to change { RetailerUser.count }.by(1)
    end
  end
end
