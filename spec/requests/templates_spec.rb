require 'rails_helper'

RSpec.describe 'TemplatesController', type: :request do
  let(:retailer) { create(:retailer) }
  let(:another_retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }
  let(:another_retailer_user) { create(:retailer_user, retailer: retailer) }

  describe 'GET #index' do
    context 'when the retailer is not logged in' do
      it 'redirects to login page' do
        get retailers_templates_path(retailer)
        expect(response).to redirect_to('/login')
      end
    end

    context 'when the retailer is logged in' do
      let(:retailer_user_agent) { create(:retailer_user, :agent, retailer: retailer) }

      before do
        sign_in retailer_user_agent
        create_list(:template, 3, retailer: retailer)
        create_list(:template, 2, retailer: retailer, retailer_user: retailer_user_agent)
        create_list(:template, 4, retailer: retailer, retailer_user: retailer_user)
      end

      it 'only returns his owned templates and those that do not have owner' do
        get retailers_templates_path(retailer)

        expect(response).to have_http_status(:ok)
        expect(assigns(:templates).size).to eq(5)
      end
    end
  end

  describe 'POST #create' do
    before do
      sign_in retailer_user
    end

    context 'when mandatory data is sent' do
      it 'creates a new template' do
        expect {
          post retailers_templates_path(retailer), params: {
            template: {
              title: 'Nueva template',
              answer: 'Text de prueba'
            }
          }
        }.to change(Template, :count).by(1)

        expect(Template.last.retailer_user_id).to eq(retailer_user.id)
      end
    end

    context 'when mandatory data is not sent' do
      it 'does not create a new template' do
        expect {
          post retailers_templates_path(retailer), params: {
            template: {
              title: '',
              answer: 'Text de prueba'
            }
          }
        }.to change(Template, :count).by(0)
      end
    end
  end

  describe 'GET #show' do
    context 'when the template does not exist' do
      it 'redirects to dashboard page' do
        sign_in retailer_user
        get retailers_template_path(retailer, 'anywebid')
        expect(response).to redirect_to("/retailers/#{retailer.slug}/dashboard")
      end
    end

    context 'when the retailer in session is not the owner' do
      let(:template) { create(:template, retailer: another_retailer) }

      it 'redirects to dashboard page' do
        sign_in retailer_user
        get retailers_template_path(retailer, template)
        expect(response).to redirect_to("/retailers/#{retailer.slug}/dashboard")
      end
    end

    context 'when the current retailer user is an agent' do
      let(:retailer_user_agent) { create(:retailer_user, :agent, retailer: retailer) }

      before do
        sign_in retailer_user_agent
      end

      context 'when it is not the template creator' do
        let(:template) { create(:template, retailer: retailer, retailer_user: retailer_user) }

        it 'does not allow the access to the template' do
          get retailers_template_path(retailer, template)

          expect(response).to have_http_status(:found)
          expect(response).to redirect_to("/retailers/#{retailer.slug}/templates")
          expect(flash[:notice]).to eq('No tienes permisos sobre la respuesta')
        end
      end

      context 'when it is the template creator' do
        let(:template) { create(:template, retailer: retailer, retailer_user: retailer_user_agent) }

        it 'allows the access to the template' do
          get retailers_template_path(retailer, template)

          expect(response).to have_http_status(:ok)
          expect(assigns(:template)).to eq(template)
        end
      end

      context 'when the template does not have an agent associated' do
        let(:template) { create(:template, retailer: retailer) }

        it 'allows the access to the template' do
          get retailers_template_path(retailer, template)

          expect(response).to have_http_status(:ok)
          expect(assigns(:template)).to eq(template)
        end
      end
    end

    context 'when the current retailer user is an admin' do
      let(:retailer_user_admin) { create(:retailer_user, :admin, retailer: retailer) }
      let(:template) { create(:template, retailer: retailer, retailer_user: retailer_user) }

      it 'allows the access to the template' do
        sign_in retailer_user_admin
        get retailers_template_path(retailer, template)

        expect(response).to have_http_status(:ok)
        expect(assigns(:template)).to eq(template)
      end
    end

    context 'when the current retailer user is a supervisor' do
      let(:retailer_user_supervisor) { create(:retailer_user, :supervisor, retailer: retailer) }
      let(:template) { create(:template, retailer: retailer, retailer_user: retailer_user) }

      it 'allows the access to the template' do
        sign_in retailer_user_supervisor
        get retailers_template_path(retailer, template)

        expect(response).to have_http_status(:ok)
        expect(assigns(:template)).to eq(template)
      end
    end
  end

  describe 'GET #templates_for_questions' do
    context 'when the templates are global' do
      before do
        sign_in retailer_user
        create_list(:template, 3, :for_questions_ml, :global_template, retailer: retailer, retailer_user:
          another_retailer_user)
        create_list(:template, 4, :for_questions_ml, retailer: retailer, retailer_user: another_retailer_user)
      end

      it 'returns the templates to all agents' do
        get retailers_templates_templates_for_questions_path

        expect(JSON.parse(response.body).size).to eq(3)
      end
    end

    context 'when the templates do not have associated retailer user' do
      before do
        sign_in retailer_user
        create_list(:template, 3, :for_questions_ml, retailer: retailer, retailer_user:
          another_retailer_user)
        create_list(:template, 4, :for_questions_ml, retailer: retailer)
      end

      it 'returns the templates to all agents' do
        get retailers_templates_templates_for_questions_path

        expect(JSON.parse(response.body).size).to eq(4)
      end
    end

    context 'when the templates are not global and they have retailer user associated' do
      let(:retailer_user_agent) { create(:retailer_user, :agent, retailer: retailer) }

      before do
        sign_in retailer_user_agent
      end

      context 'when it is not the templates creator' do
        before do
          create_list(:template, 3, :for_questions_ml, retailer: retailer, retailer_user:
            another_retailer_user)
          create_list(:template, 4, :for_questions_ml, retailer: retailer, retailer_user: retailer_user)
        end

        it 'does not return any template' do
          get retailers_templates_templates_for_questions_path

          expect(JSON.parse(response.body).size).to eq(0)
        end
      end

      context 'when it is the templates creator' do
        before do
          create_list(:template, 3, :for_questions_ml, retailer: retailer, retailer_user:
            another_retailer_user)
          create_list(:template, 4, :for_questions_ml, retailer: retailer, retailer_user: retailer_user_agent)
        end

        it 'returns the templates belonging to it' do
          get retailers_templates_templates_for_questions_path

          expect(JSON.parse(response.body).size).to eq(4)
        end
      end
    end

    context 'when search param is present' do
      before do
        sign_in retailer_user
        create(:template, :for_questions_ml, retailer: retailer, title: 'Titulo de prueba', answer: 'Anything')
        create(:template, :for_questions_ml, retailer: retailer, title: 'Otro titulo', answer: 'Anything')
        create(:template, :for_questions_ml, retailer: retailer, title: 'Anything', answer: 'Otra prueba')
        create(:template, :for_messages_ml, retailer: retailer, title: 'Titulo', answer: 'Otra prueba')
      end

      it 'filters by title' do
        get retailers_templates_templates_for_questions_path, params: { search: 'titulo' }
        body = JSON.parse(response.body)

        expect(body.size).to eq(2)
        expect(body[0]['title']).to include('Titulo')
      end

      it 'filters by content' do
        get retailers_templates_templates_for_questions_path, params: { search: 'otra' }
        body = JSON.parse(response.body)

        expect(body.size).to eq(1)
        expect(body[0]['answer']).to include('Otra prueba')
      end
    end
  end

  describe 'GET #templates_for_chats' do
    context 'when the templates are global' do
      before do
        sign_in retailer_user
        create_list(:template, 3, :for_messages_ml, :global_template, retailer: retailer, retailer_user:
          another_retailer_user)
        create_list(:template, 4, :for_messages_ml, retailer: retailer, retailer_user: another_retailer_user)
      end

      it 'returns the templates to all agents' do
        get retailers_templates_templates_for_chats_path

        expect(JSON.parse(response.body).size).to eq(3)
      end
    end

    context 'when the templates do not have associated retailer user' do
      before do
        sign_in retailer_user
        create_list(:template, 3, :for_messages_ml, retailer: retailer, retailer_user:
          another_retailer_user)
        create_list(:template, 4, :for_messages_ml, retailer: retailer)
      end

      it 'returns the templates to all agents' do
        get retailers_templates_templates_for_chats_path

        expect(JSON.parse(response.body).size).to eq(4)
      end
    end

    context 'when the templates are not global and they have retailer user associated' do
      let(:retailer_user_agent) { create(:retailer_user, :agent, retailer: retailer) }

      before do
        sign_in retailer_user_agent
      end

      context 'when it is not the templates creator' do
        before do
          create_list(:template, 3, :for_messages_ml, retailer: retailer, retailer_user:
            another_retailer_user)
          create_list(:template, 4, :for_messages_ml, retailer: retailer, retailer_user: retailer_user)
        end

        it 'does not return any template' do
          get retailers_templates_templates_for_chats_path

          expect(JSON.parse(response.body).size).to eq(0)
        end
      end

      context 'when it is the templates creator' do
        before do
          create_list(:template, 3, :for_messages_ml, retailer: retailer, retailer_user:
            another_retailer_user)
          create_list(:template, 4, :for_messages_ml, retailer: retailer, retailer_user: retailer_user_agent)
        end

        it 'returns the templates belonging to it' do
          get retailers_templates_templates_for_chats_path

          expect(JSON.parse(response.body).size).to eq(4)
        end
      end
    end

    context 'when search param is present' do
      before do
        sign_in retailer_user
        create(:template, :for_messages_ml, retailer: retailer, title: 'Titulo de prueba', answer: 'Anything')
        create(:template, :for_messages_ml, retailer: retailer, title: 'Otro titulo', answer: 'Anything')
        create(:template, :for_messages_ml, retailer: retailer, title: 'Anything', answer: 'Otra prueba')
        create(:template, :for_questions_ml, retailer: retailer, title: 'Titulo', answer: 'Otra prueba')
      end

      it 'filters by title' do
        get retailers_templates_templates_for_chats_path, params: { search: 'titulo' }
        body = JSON.parse(response.body)

        expect(body.size).to eq(2)
        expect(body[0]['title']).to include('Titulo')
      end

      it 'filters by content' do
        get retailers_templates_templates_for_chats_path, params: { search: 'otra prueba' }
        body = JSON.parse(response.body)

        expect(body.size).to eq(1)
        expect(body[0]['answer']).to include('Otra prueba')
      end
    end
  end
end
