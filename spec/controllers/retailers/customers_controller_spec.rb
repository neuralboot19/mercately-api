require 'rails_helper'

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
            'first_name_or_last_name_or_phone_or_email_cont': @customers_a1.first.email,
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
            'first_name_or_last_name_or_phone_or_email_cont': @customers_a1.first.email,
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
            'first_name_or_last_name_or_phone_or_email_cont': @customers_a1.first.email,
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
            'first_name_or_last_name_or_phone_or_email_cont': @customer_a2.email
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

        expect(flash[:notice]).to match("Disculpe, no posee permisos sobre el cliente #{@customer_a2.full_names}")
        expect(
          get :index, params: { slug: agent1.retailer.slug, q: { agent_id: nil} }
        ).to render_template('retailers/customers/index')
      end
    end
  end
end