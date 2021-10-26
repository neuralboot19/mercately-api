require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

RSpec.describe Retailers::CustomersController, type: :controller do
  describe 'GET #index' do
    let(:agent1) { create(:retailer_user, :with_retailer, :agent) }
    let(:agent2) { create(:retailer_user, :with_retailer, :agent, retailer: agent1.retailer) }

    before do
      @customers_a1 = create_list(:customer, 4, retailer: agent1.retailer)
      @customers_a1.each do |customer|
        create(:agent_customer, customer: customer, retailer_user: agent1)
      end

      @customer_a2 = create(:customer, retailer: agent2.retailer)
      create(:agent_customer, customer: @customer_a2, retailer_user: agent2)

      create(:customer, retailer: agent2.retailer)
    end

    context 'when current_retailer_user is admin' do
      let(:retailer_user) { create(:retailer_user, :admin, retailer: agent1.retailer) }

      before do
        sign_in retailer_user
      end

      it 'shows all customers' do
        get :index, params: { slug: retailer_user.retailer.slug, q: { s: 'created_at desc'} }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(6)
      end

      it 'filters by param' do
        get :index, params: {
          slug: retailer_user.retailer.slug,
          q: {
            'first_name_or_last_name_or_phone_or_email_or_whatsapp_name_cont': @customers_a1.first.email,
            s: 'created_at desc',
            agent_id: nil
          }
        }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(1)
      end

      it 'filters by any agent_id' do
        get :index, params: {
          slug: agent1.retailer.slug,
          q: { agent_id: agent1.id }
        }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(4)


        get :index, params: {
          slug: agent1.retailer.slug,
          q: { agent_id: agent2.id }
        }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(1)
      end
    end

    context 'when current_retailer_user is supervisor' do
      let(:retailer_user) { create(:retailer_user, :supervisor, retailer: agent1.retailer) }

      before do
        sign_in retailer_user
      end

      it 'shows all customers' do
        get :index, params: { slug: retailer_user.retailer.slug, q: { s: 'created_at desc'} }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(6)
      end

      it 'filters by param' do
        get :index, params: {
          slug: retailer_user.retailer.slug,
          q: {
            'first_name_or_last_name_or_phone_or_email_or_whatsapp_name_cont': @customers_a1.first.email,
            s: 'created_at desc',
            agent_id: nil
          }
        }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(1)
      end

      it 'filters by any agent_id' do
        get :index, params: {
          slug: agent1.retailer.slug,
          q: { agent_id: agent1.id }
        }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(4)


        get :index, params: {
          slug: agent1.retailer.slug,
          q: { agent_id: agent2.id }
        }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(1)
      end
    end

    context 'when current_retailer_user is agent' do
      before do
        sign_in agent1
      end

      it 'shows only customers assigned to current user and those not assigned' do
        get :index, params: { slug: agent1.retailer.slug, q: { s: 'created_at desc'} }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(5)
      end

      it 'filters by param' do
        get :index, params: {
          slug: agent1.retailer.slug,
          q: {
            'first_name_or_last_name_or_phone_or_email_or_whatsapp_name_cont': @customers_a1.first.email,
            s: 'created_at desc'
          }
        }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(1)
      end

      it 'does not filters by param if customer not assigned' do
        get :index, params: {
          slug: agent1.retailer.slug,
          q: {
            'first_name_or_last_name_or_phone_or_email_or_whatsapp_name_cont': @customer_a2.email
          }
        }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(0)
      end

      it 'filters by agent_id' do
        get :index, params: {
          slug: agent1.retailer.slug,
          q: { agent_id: agent1.id }
        }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(4)
      end

      it 'filters by self if agent_id not current retailer user id' do
        get :index, params: {
          slug: agent1.retailer.slug,
          q: { agent_id: agent2.id }
        }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(4)
      end

      it 'shows all customers allowed if agent_id not present' do
        get :index, params: { slug: agent1.retailer.slug }

        expect(response).to have_http_status(:ok)
        expect(assigns(:customers).count).to eq(5)
      end
    end

    context 'when filters include tags' do
      let(:retailer) { create(:retailer) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }
      let(:customer) { create(:customer, retailer: retailer) }
      let(:customer2) { create(:customer, retailer: retailer) }
      let(:customer3) { create(:customer, retailer: retailer) }
      let(:tag) { create(:tag, retailer: retailer) }
      let(:tag2) { create(:tag, retailer: retailer) }
      let(:tag3) { create(:tag, retailer: retailer) }
      let(:tag4) { create(:tag, retailer: retailer) }
      let!(:customer_tag) { create(:customer_tag, customer: customer, tag: tag) }
      let!(:customer_tag2) { create(:customer_tag, customer: customer2, tag: tag) }
      let!(:customer_tag3) { create(:customer_tag, customer: customer3, tag: tag) }
      let!(:customer_tag4) { create(:customer_tag, customer: customer, tag: tag2) }
      let!(:customer_tag5) { create(:customer_tag, customer: customer, tag: tag3) }
      let!(:customer_tag6) { create(:customer_tag, customer: customer2, tag: tag2) }

      before do
        sign_in retailer_user
      end

      context 'when one tag is sent' do
        it 'returns only the customers belonging to all tags sent' do
          get :index, params: {
            slug: retailer.slug,
            q: { customer_tags_tag_id_in: [tag.id] }
          }

          expect(response).to have_http_status(:ok)
          expect(assigns(:customers).count).to eq(3)
        end
      end

      context 'when two tags are sent' do
        it 'returns only the customers belonging to all tags sent' do
          get :index, params: {
            slug: retailer.slug,
            q: { customer_tags_tag_id_in: [tag.id, tag2.id] }
          }

          expect(response).to have_http_status(:ok)
          expect(assigns(:customers).count).to eq(2)
        end
      end

      context 'when three tags are sent' do
        it 'returns only the customers belonging to all tags sent' do
          get :index, params: {
            slug: retailer.slug,
            q: { customer_tags_tag_id_in: [tag.id, tag2.id, tag3.id] }
          }

          expect(response).to have_http_status(:ok)
          expect(assigns(:customers).count).to eq(1)
        end
      end

      context 'when four tags are sent' do
        it 'returns only the customers belonging to all tags sent' do
          get :index, params: {
            slug: retailer.slug,
            q: { customer_tags_tag_id_in: [tag.id, tag2.id, tag3.id, tag4.id] }
          }

          expect(response).to have_http_status(:ok)
          expect(assigns(:customers).count).to eq(0)
        end
      end
    end

    context 'when filters do not include tags' do
      let(:retailer) { create(:retailer) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }
      let(:customer) { create(:customer, retailer: retailer) }
      let(:customer2) { create(:customer, retailer: retailer) }
      let(:customer3) { create(:customer, retailer: retailer) }
      let(:tag) { create(:tag, retailer: retailer) }
      let(:tag2) { create(:tag, retailer: retailer) }
      let(:tag3) { create(:tag, retailer: retailer) }
      let(:tag4) { create(:tag, retailer: retailer) }
      let!(:customer_tag) { create(:customer_tag, customer: customer, tag: tag) }
      let!(:customer_tag2) { create(:customer_tag, customer: customer2, tag: tag) }
      let!(:customer_tag3) { create(:customer_tag, customer: customer3, tag: tag) }
      let!(:customer_tag4) { create(:customer_tag, customer: customer, tag: tag2) }
      let!(:customer_tag5) { create(:customer_tag, customer: customer, tag: tag3) }
      let!(:customer_tag6) { create(:customer_tag, customer: customer2, tag: tag2) }

      before do
        sign_in retailer_user
      end

      context 'when it sends the tags array empty' do
        it 'returns all the customers' do
          get :index, params: {
            slug: retailer.slug,
            q: { customer_tags_tag_id_in: [] }
          }

          expect(response).to have_http_status(:ok)
          expect(assigns(:customers).count).to eq(3)
        end
      end

      context 'when the tags array is not sent' do
        it 'returns all the customers' do
          get :index, params: {
            slug: retailer.slug
          }

          expect(response).to have_http_status(:ok)
          expect(assigns(:customers).count).to eq(3)
        end
      end
    end

    context 'when filters include groups' do
      let(:retailer) { create(:retailer) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }
      let!(:contact_group) { create(:contact_group, :with_customers, retailer: retailer) }

      before do
        sign_in retailer_user
      end

      context 'when group is selected' do
        it 'returns only the customers belonging to all tags sent' do
          get :index, params: {
            slug: retailer.slug,
            q: { contact_group_id: contact_group.id }
          }

          expect(response).to have_http_status(:ok)
          expect(assigns(:customers).count).to eq(3)
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when current_retailer_user is admin' do
      let(:retailer_user) { create(:retailer_user, :with_retailer, :admin) }
      let(:customer) { create(:customer, retailer: retailer_user.retailer) }

      before do
        sign_in retailer_user
      end

      it 'renders the view' do
        expect(
          get :show, params: { slug: retailer_user.retailer.slug, id: customer.web_id }
        ).to render_template('retailers/customers/show')
      end
    end

    context 'when current_retailer_user is supervisor' do
      let(:retailer_user) { create(:retailer_user, :with_retailer, :supervisor) }
      let(:customer) { create(:customer, retailer: retailer_user.retailer) }

      before do
        sign_in retailer_user
      end

      it 'renders the view' do
        expect(
          get :show, params: { slug: retailer_user.retailer.slug, id: customer.web_id }
        ).to render_template('retailers/customers/show')
      end
    end

    context 'when current_retailer_user is agent' do
      let(:agent1) { create(:retailer_user, :with_retailer, :agent) }
      let(:agent2) { create(:retailer_user, :with_retailer, :agent, retailer: agent1.retailer) }

      before do
        @customers_a1 = create_list(:customer, 4, retailer: agent1.retailer)
        @customers_a1.each do |customer|
          create(:agent_customer, customer: customer, retailer_user: agent1)
        end

        @customer_a2 = create(:customer, retailer: agent2.retailer)
        create(:agent_customer, customer: @customer_a2, retailer_user: agent2)

        @customer_not_agent = create(:customer, retailer: agent2.retailer)
        sign_in agent1
      end

      it 'renders the view if customer has no agent assigned' do
        expect(
          get :show, params: { slug: agent1.retailer.slug, id: @customer_not_agent.web_id }
        ).to render_template('retailers/customers/show')
      end

      it 'renders the view if customer is asigned to the agent' do
        expect(
          get :show, params: { slug: agent1.retailer.slug, id: @customers_a1.first.web_id }
        ).to render_template('retailers/customers/show')
      end

      it 'does not render the view if customer is not asigned to the agent' do
        expect(
          get :show, params: { slug: agent1.retailer.slug, id: @customer_a2.web_id }
        ).to_not render_template('retailers/customers/show')

        expect(flash[:notice]).to match('Disculpe, no posee permisos para ver esta página')
        expect(
          get :index, params: { slug: agent1.retailer.slug, q: { agent_id: nil} }
        ).to render_template('retailers/customers/index')
      end
    end
  end

  describe 'GET #import' do
    context 'when has permissions' do
      let(:retailer_user) { create(:retailer_user, :admin, :with_retailer) }

      before do
        sign_in retailer_user
      end

      it 'renders the view' do
        expect(
          get :import, params: { slug: retailer_user.retailer.slug }
        ).to render_template('retailers/customers/import')
      end
    end

    context 'when has no permissions' do
      let(:agent) { create(:retailer_user, :agent, :with_retailer) }
      before do
        sign_in agent
      end

      it 'redirects to retailers customers view' do
        get :import, params: { slug: agent.retailer.slug }

        expect(flash[:notice]).to match('Disculpe, no posee permisos para ver esta página')

        slug = agent.retailer.slug
        redirect_url = "/retailers/#{slug}/customers?q%5Bs%5D=created_at+desc&slug=#{slug}"
        expect(response).to redirect_to(redirect_url)
      end
    end
  end

  describe 'POST #bulk_import' do
    context 'when has permissions' do
      let(:retailer_user) { create(:retailer_user, :admin, :with_retailer) }
      let(:retailer) { retailer_user.retailer }

      before do
        create(:customer, retailer: retailer)
        create(:customer, retailer: retailer, phone: '55555555', country_id: 'EC')

        sign_in retailer_user
      end

      it 'redirects to import view if not file sent' do
        post :bulk_import, params: { slug: retailer.slug }

        expect(flash[:notice]).to match('Debe seleccionar un archivo')
        expect(response).to redirect_to(retailers_customers_import_path(retailer.slug))
      end

      it 'returns an error if not a csv file' do
        post :bulk_import, params: {
          slug: retailer.slug,
          csv_file: fixture_file_upload(Rails.root + 'spec/fixtures/dummy.pdf', 'application/pdf')
        }

        expect(flash[:notice][0]).to include('Tipo de archivo inválido. Debe ser CSV (.csv) o Excel (.xlsx)')
        expect(response).to redirect_to(retailers_customers_import_path(retailer.slug))
      end

      it 'returns an error if csv columns not match' do
        post :bulk_import, params: {
          slug: retailer.slug,
          csv_file: fixture_file_upload(Rails.root + 'spec/fixtures/wrong_columns_customers.csv', 'text/csv')
        }

        expect(flash[:notice][0]).to include('Las columnas del archivo no coinciden')
        expect(response).to redirect_to(retailers_customers_import_path(retailer.slug))
      end

      it 'returns an error when csv is empty' do
        post :bulk_import, params: {
          slug: retailer.slug,
          csv_file: fixture_file_upload(Rails.root + 'spec/fixtures/empty_customers.csv', 'text/csv')
        }

        expect(flash[:notice][0]).to include('El archivo está vacío')
        expect(response).to redirect_to(retailers_customers_import_path(retailer.slug))
      end

      context 'when it is a csv file' do
        let(:file) { File.open(Rails.root + 'spec/fixtures/customers.csv') }

        before do
          allow_any_instance_of(ImportContactsLogger).to receive(:file_url).and_return('https://mercately.com')
          allow_any_instance_of(ImportContactsLogger).to receive(:delete_file).and_return(true)
          allow_any_instance_of(Customers::ImportCustomersJob).to receive(:open).and_return(file)
        end

        it 'returns success message' do
          post :bulk_import, params: {
            slug: retailer.slug,
            csv_file: fixture_file_upload(Rails.root + 'spec/fixtures/customers.csv', 'text/csv')
          }

          expect(flash[:notice][0]).to include('La importación está en proceso. Recibirá un correo cuando ' \
            'haya culminado.')
          expect(response).to redirect_to(retailers_customers_import_path(retailer.slug))
        end
      end

      context 'when it is an excel file' do
        let(:file) { Roo::Spreadsheet.open(Rails.root + 'spec/fixtures/customers.xlsx', extension: :xlsx) }

        before do
          allow_any_instance_of(ImportContactsLogger).to receive(:file_url).and_return('https://mercately.com')
          allow_any_instance_of(ImportContactsLogger).to receive(:delete_file).and_return(true)
          allow(Roo::Spreadsheet).to receive(:open).and_return(file)
        end

        it 'returns success message' do
          post :bulk_import, params: {
            slug: retailer.slug,
            csv_file: fixture_file_upload(Rails.root + 'spec/fixtures/customers.xlsx',
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
          }

          expect(flash[:notice][0]).to include('La importación está en proceso. Recibirá un correo cuando ' \
            'haya culminado.')
          expect(response).to redirect_to(retailers_customers_import_path(retailer.slug))
        end
      end
    end

    context 'when has no permissions' do
      let(:agent) { create(:retailer_user, :agent, :with_retailer) }
      before do
        sign_in agent
      end

      it 'redirects to retailers customers view' do
        get :import, params: { slug: agent.retailer.slug }

        expect(flash[:notice]).to match('Disculpe, no posee permisos para ver esta página')

        slug = agent.retailer.slug
        redirect_url = "/retailers/#{slug}/customers?q%5Bs%5D=created_at+desc&slug=#{slug}"
        expect(response).to redirect_to(redirect_url)
      end
    end
  end
end
