require 'rails_helper'

RSpec.describe 'Templates', type: :request, skip: true do
  describe 'GET /templates' do
    it 'works! (now write some real specs)' do
      get templates_path
      expect(response).to have_http_status(:ok)
    end
  end
end
