require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'POST #request_demo' do
    it 'sends an email to admins and shows the index' do
      get '/'
      expect(response).to render_template(:index)

      post '/request_demo', params: { name: 'John Doe', email: 'john@doe.com', phone: '098-333-4444' }
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(response).to redirect_to('/')

      follow_redirect!
      expect(response).to render_template(:index)
      expect(response.body).to include('Gracias! Nuestro equipo se contactará pronto.')
    end
  end
end
