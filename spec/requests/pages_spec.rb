require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'POST #request_demo' do
    it 'sends an email to admins and shows the index' do
      get '/'
      expect(response).to render_template(:index)

      post '/request_demo', params: {
        name: 'John Doe',
        email: 'john@doe.com',
        company: 'Test',
        country: 'EC',
        phone: '098-333-4444',
        message: 'Test',
        problem_to_resolve: 'Test'
      }
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(response).to redirect_to('/')

      follow_redirect!
      expect(response).to render_template(:index)
      expect(response.body).to include('Gracias! Nuestro equipo se contactará pronto.')
    end

    context 'with from-ws-crm present' do
      it 'sends an email to admins params and shows the index ' do
        get '/'
        expect(response).to render_template(:index)

        post '/request_demo', params: {
          name: 'John Doe',
          email: 'john@doe.com',
          company: 'Test',
          country: 'EC',
          phone: '098-333-4444',
          message: 'Test',
          problem_to_resolve: 'Test',
          'from-ws-crm': true,
          'g-recaptcha-response': 'schedule'
        }
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(response).to redirect_to whatsapp_crm_path

        follow_redirect!
        expect(response).to render_template(:whatsapp_crm)
        expect(response.body).to include('Gracias! Nuestro equipo se contactará pronto.')
      end

      it 'sends email to admins with invalid reCAPTCHA and renders view whatsapp_crm' do
        get '/'
        expect(response).to render_template(:index)
        expect_any_instance_of(PagesController).to receive(:verify_recaptcha).and_return(false)

        post '/request_demo', params: {
          name: 'John Doe',
          email: 'john@doe.com',
          company: 'Test',
          country: 'EC',
          phone: '098-333-4444',
          message: 'Test',
          problem_to_resolve: 'Test',
          'from-ws-crm': true
        }
        expect(assigns(:show_checkbox_recaptcha)).to eq(true)
        expect(response).to redirect_to(whatsapp_crm_path)
      end
    end

    it 'sends email to admins with invalid reCAPTCHA and renders view index ' do
      get '/'
      expect(response).to render_template(:index)
      expect_any_instance_of(PagesController).to receive(:verify_recaptcha).and_return(false)

      post '/request_demo', params: {
        name: 'John Doe',
        email: 'john@doe.com',
        company: 'Test',
        country: 'EC',
        phone: '098-333-4444',
        message: 'Test',
        problem_to_resolve: 'Test'
      }
      expect(assigns(:show_checkbox_recaptcha)).to eq(true)
      expect(response).to redirect_to(root_path)
    end
  end
end
