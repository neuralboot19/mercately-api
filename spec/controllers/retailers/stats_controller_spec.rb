require 'rails_helper'

RSpec.describe 'StatsController', type: :request do
  before do
    now = Time.parse("2020-07-20 10:17:40")
    date = Time.parse("2020-07-20 10:17:40")
    allow(Time).to receive(:now) { now }
    allow(Date).to receive(:today) { date }
  end

  describe '#index' do
    let(:retailer) { create(:retailer) }

    context 'when the retailer is not logged in' do
      it 'redirects to login page' do
        get retailers_stats_path(retailer)

        expect(response).to redirect_to('/login')
      end
    end

    context 'when the retailer is logged in' do
      context 'when the retailer is an admin' do
        let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }

        it 'responses ok' do
          sign_in retailer_user
          get retailers_stats_path(retailer)

          expect(response).to have_http_status(:ok)
        end
      end

      context 'when the retailer is a supervisor' do
        let(:retailer_user) { create(:retailer_user, :supervisor, retailer: retailer) }

        it 'responses ok' do
          sign_in retailer_user
          get retailers_stats_path(retailer)

          expect(response).to have_http_status(:ok)
        end
      end

      context 'when the retailer is an agent' do
        let(:retailer_user) { create(:retailer_user, :agent, retailer: retailer) }

        it 'redirects to dashboard page' do
          sign_in retailer_user
          get retailers_stats_path(retailer)

          expect(response).to have_http_status(:found)
          expect(response).to redirect_to("/retailers/#{retailer.slug}/dashboard")
        end
      end
    end
  end

  describe '#total_messages_stats' do
    let(:customer_old) { create(:customer, retailer: retailer, created_at: Time.now - 8.days) }
    let(:customer_old2) { create(:customer, retailer: retailer, created_at: Time.now - 8.days) }
    let(:customer) { create(:customer, retailer: retailer) }
    let(:customer2) { create(:customer, retailer: retailer) }

    context 'when the retailer is whatsapp integrated' do
      context 'with karix integrated' do
        let(:retailer) { create(:retailer, :karix_integrated, :with_stats) }
        let(:retailer_user) { create(:retailer_user, retailer: retailer) }

        before do
          sign_in retailer_user
          create(:karix_whatsapp_message, :inbound, retailer: retailer, customer: customer, created_at:
            Time.now - 25.hours)
          create(:karix_whatsapp_message, :inbound, retailer: retailer, customer: customer, created_at:
            Time.now - 26.hours)
          create(:karix_whatsapp_message, :inbound, retailer: retailer, customer: customer, created_at:
            Time.now - 51.hours)
          create(:agent_customer, retailer_user: retailer_user, customer: customer, updated_at: Time.now - 25.hours)
          create(:karix_whatsapp_message, :inbound, retailer: retailer, customer: customer_old, created_at:
            Time.now - 5.hours)
          create(:agent_customer, retailer_user: retailer_user, customer: customer_old, updated_at: Time.now - 5.hours)
          create(:karix_whatsapp_message, :inbound, retailer: retailer, customer: customer2, created_at:
            Time.now - 8.days)
          create(:agent_customer, retailer_user: retailer_user, customer: customer2, updated_at: Time.now - 8.days)

          create_list(:karix_whatsapp_message, 3, :outbound, :conversation, retailer: retailer, retailer_user:
            retailer_user, customer: customer, created_at: Time.now - 10.hours)
          create_list(:karix_whatsapp_message, 2, :outbound, :conversation, retailer: retailer, retailer_user:
            retailer_user, customer: customer2, created_at: Time.now - 8.days)
        end

        context 'when a date range is not passed' do
          it 'loads the total inbound and outbound messages for the last 5 days' do
            get retailers_total_messages_stats_path(retailer)

            expect(assigns(:total_inbound_ws)).to eq(4)
            expect(assigns(:total_outbound_ws)).to eq(3)
            expect(assigns(:ws_prospects)).to eq(1)
            expect(assigns(:ws_currents)).to eq(1)
          end

          it 'counts the total and answered chats for the last 5 days' do
            get retailers_total_messages_stats_path(retailer)

            expect(assigns(:total_ws)).to eq(2)
            expect(assigns(:total_answered_ws)).to eq(1)
          end
        end

        context 'when a date range is passed' do
          it 'loads the total inbound and outbound messages for the date range' do
            get retailers_total_messages_stats_path(retailer), params:
              {
                search: {
                  range: (Date.today - 9.days).to_s + ' - ' + (Date.today - 1.days).to_s
                }
              }

            expect(assigns(:total_inbound_ws)).to eq(4)
            expect(assigns(:total_outbound_ws)).to eq(2)
            expect(assigns(:ws_prospects)).to eq(0)
            expect(assigns(:ws_currents)).to eq(2)
          end

          it 'counts the total and answered chats for the date range' do
            get retailers_total_messages_stats_path(retailer), params:
              {
                search: {
                  range: (Date.today - 9.days).to_s + ' - ' + (Date.today - 1.days).to_s
                }
              }

            expect(assigns(:total_ws)).to eq(2)
            expect(assigns(:total_answered_ws)).to eq(1)
          end
        end
      end

      context 'with GupShup integrated' do
        let(:retailer) { create(:retailer, :gupshup_integrated, :with_stats) }
        let(:retailer_user) { create(:retailer_user, retailer: retailer) }

        before do
          sign_in retailer_user

          create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer_old, created_at:
            Time.now - 29.hours)
          create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer_old, created_at:
            Time.now - 30.hours)
          create(:agent_customer, retailer_user: retailer_user, customer: customer_old, updated_at: Time.now - 30.hours)
          create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer_old2, created_at:
            Time.now - 8.days)
          create(:agent_customer, retailer_user: retailer_user, customer: customer_old2, updated_at: Time.now - 8.days)

          create_list(:gupshup_whatsapp_message, 3, :outbound, :notification, retailer: retailer, retailer_user:
            retailer_user, customer: customer_old, created_at: Time.now - 2.hours)
          create_list(:gupshup_whatsapp_message, 2, :outbound, :conversation, retailer: retailer, retailer_user:
            retailer_user, customer: customer_old2, created_at: Date.today - 8.days)
        end

        context 'when a date range is not passed' do
          it 'loads the total inbound and outbound messages for the last 5 days' do
            get retailers_total_messages_stats_path(retailer)

            expect(assigns(:total_inbound_ws)).to eq(2)
            expect(assigns(:total_outbound_ws)).to eq(3)
            expect(assigns(:ws_prospects)).to eq(0)
            expect(assigns(:ws_currents)).to eq(1)
          end

          it 'counts the total and answered chats for the last 5 days' do
            get retailers_total_messages_stats_path(retailer)

            expect(assigns(:total_ws)).to eq(1)
            expect(assigns(:total_answered_ws)).to eq(0)
          end
        end

        context 'when a date range is passed' do
          it 'loads the total inbound and outbound messages for the date range' do
            get retailers_total_messages_stats_path(retailer), params:
              {
                search: {
                  range: (Date.today - 9.days).to_s + ' - ' + (Date.today - 1.days).to_s
                }
              }

            expect(assigns(:total_inbound_ws)).to eq(3)
            expect(assigns(:total_outbound_ws)).to eq(2)
            expect(assigns(:ws_prospects)).to eq(2)
            expect(assigns(:ws_currents)).to eq(0)
          end

          it 'counts the total and answered chats for the date range' do
            get retailers_total_messages_stats_path(retailer), params:
              {
                search: {
                  range: (Date.today - 9.days).to_s + ' - ' + (Date.today - 1.days).to_s
                }
              }

            expect(assigns(:total_ws)).to eq(2)
            expect(assigns(:total_answered_ws)).to eq(1)
          end
        end
      end
    end

    context 'when the retailer is messenger integrated' do
      let(:retailer) { create(:retailer, :with_stats) }
      let!(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }

      before do
        sign_in retailer_user

        create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer_old2,
          created_at: Time.now - 25.hours)
        create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer_old2,
          created_at: Time.now - 60.hours)
        create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer,
          created_at: Time.now - 29.hours)
        create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer, created_at:
          Time.now)
        create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer2, created_at:
          Time.now)
        create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer, created_at:
          Time.now - 8.days)
        create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer_old, created_at:
          Time.now - 8.days)

        create_list(:facebook_message, 3, :outbound, facebook_retailer: facebook_retailer, retailer_user:
          retailer_user, customer: customer_old2, created_at: Time.now - 1.hours)
        create_list(:facebook_message, 2, :outbound, facebook_retailer: facebook_retailer, retailer_user:
          retailer_user, customer: customer_old, created_at: Time.now - 6.days)

        # Se eliminan las asignaciones creadas automaticamente porque no concuerdan las fechas con las pruebas
        retailer_user.agent_customers.destroy_all
        create(:agent_customer, retailer_user: retailer_user, customer: customer_old2, updated_at: Time.now - 25.hours)
        create(:agent_customer, retailer_user: retailer_user, customer: customer, updated_at: Time.now - 27.hours)
        create(:agent_customer, retailer_user: retailer_user, customer: customer2, updated_at: Time.now)
        create(:agent_customer, retailer_user: retailer_user, customer: customer_old, updated_at: Time.now - 6.days)
      end

      context 'when a date range is not passed' do
        it 'loads the total inbound and outbound messages for the last 5 days' do
          get retailers_total_messages_stats_path(retailer)

          expect(assigns(:total_inbound_msn)).to eq(5)
          expect(assigns(:total_outbound_msn)).to eq(3)
          expect(assigns(:msn_prospects)).to eq(2)
          expect(assigns(:msn_currents)).to eq(1)
        end

        it 'counts the total and answered chats for the last 5 days' do
          get retailers_total_messages_stats_path(retailer)

          expect(assigns(:total_msn)).to eq(3)
          expect(assigns(:total_answered_msn)).to eq(1)
        end
      end

      context 'when a date range is passed' do
        it 'loads the total inbound and outbound messages for the date range' do
          get retailers_total_messages_stats_path(retailer), params:
            {
              search: {
                range: (Date.today - 9.days).to_s + ' - ' + (Date.today - 1.days).to_s
              }
            }

          expect(assigns(:total_inbound_msn)).to eq(5)
          expect(assigns(:total_outbound_msn)).to eq(2)
          expect(assigns(:msn_prospects)).to eq(2)
          expect(assigns(:msn_currents)).to eq(1)
        end

        it 'counts the total and answered chats for the date range' do
          get retailers_total_messages_stats_path(retailer), params:
            {
              search: {
                range: (Date.today - 9.days).to_s + ' - ' + (Date.today - 1.days).to_s
              }
            }

          expect(assigns(:total_msn)).to eq(3)
          expect(assigns(:total_answered_msn)).to eq(1)
        end
      end
    end

    context 'when the retailer is mercadolibre integrated' do
      let(:retailer) { create(:retailer, :with_stats) }
      let!(:meli_retailer) { create(:meli_retailer, retailer: retailer) }
      let(:retailer_user) { create(:retailer_user, retailer: retailer) }

      before do
        sign_in retailer_user
        allow_any_instance_of(Question).to receive(:ml_answer_question).and_return('Question answered')
      end

      context 'when a date range is not passed' do
        before do
          create_list(:question, 2, customer: customer)
          create_list(:question, 2, customer: customer_old)
          create_list(:question, 2, customer: customer2)
          create_list(:question, 2, customer: customer_old2)
          create_list(:question, 3, customer: customer, created_at: Date.today - 8.days)
          create_list(:question, 3, customer: customer, created_at: Date.today - 8.days)
          create_list(:question, 3, :answered, customer: customer, question: nil)
          create_list(:question, 4, :answered, customer: customer, question: nil, created_at: Date.today - 8.days)

          create_list(:message, 2, customer: customer)
          create_list(:message, 2, customer: customer_old)
          create_list(:message, 2, customer: customer2)
          create_list(:message, 3, customer: customer_old2)
          create_list(:message, 3, customer: customer, created_at: Date.today - 8.days)
          create_list(:message, 3, :from_retailer, customer: customer)
          create_list(:message, 4, :from_retailer, customer: customer, created_at: Date.today - 8.days)
        end

        it 'loads the total inbound and outbound messages for the last 5 days' do
          get retailers_total_messages_stats_path(retailer)

          expect(assigns(:total_inbound_ml)).to eq(17)
          expect(assigns(:total_outbound_ml)).to eq(6)
          expect(assigns(:ml_prospects)).to eq(2)
          expect(assigns(:ml_currents)).to eq(2)
        end
      end

      context 'when a date range is passed' do
        before do
          create_list(:question, 2, customer: customer)
          create_list(:question, 3, customer: customer, created_at: Date.today - 8.days)
          create_list(:question, 3, customer: customer_old, created_at: Date.today - 8.days)
          create_list(:question, 3, :answered, customer: customer, question: nil)
          create_list(:question, 4, :answered, customer: customer, question: nil, created_at: Date.today - 8.days)

          create_list(:message, 2, customer: customer)
          create_list(:message, 3, customer: customer, created_at: Date.today - 8.days)
          create_list(:message, 3, customer: customer_old2, created_at: Date.today - 8.days)
          create_list(:message, 3, :from_retailer, customer: customer)
          create_list(:message, 4, :from_retailer, customer: customer, created_at: Date.today - 8.days)
        end

        it 'loads the total inbound and outbound messages for the date range' do
          get retailers_total_messages_stats_path(retailer), params:
            {
              search: {
                range: (Date.today - 9.days).to_s + ' - ' + (Date.today - 1.days).to_s
              }
            }

          expect(assigns(:total_inbound_ml)).to eq(12)
          expect(assigns(:total_outbound_ml)).to eq(8)
          expect(assigns(:ml_prospects)).to eq(2)
          expect(assigns(:ml_currents)).to eq(1)
        end
      end
    end

    context 'when the retailer has messages sent' do
      context 'with Whatsapp messages sent' do
        context 'when Karix integrated' do
          let(:retailer) { create(:retailer, :karix_integrated, :with_stats) }
          let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }
          let(:retailer_user2) { create(:retailer_user, :admin, retailer: retailer) }
          let(:retailer_user3) { create(:retailer_user, :supervisor, retailer: retailer) }
          let(:retailer_user4) { create(:retailer_user, :agent, retailer: retailer) }
          let(:customer_old) { create(:customer, retailer: retailer, created_at: Time.now - 10.days) }
          let(:customer_old2) { create(:customer, retailer: retailer, created_at: Time.now - 10.days) }
          let(:customer) { create(:customer, retailer: retailer) }
          let(:customer2) { create(:customer, retailer: retailer) }

          before do
            sign_in retailer_user

            create_list(:karix_whatsapp_message, 2, :outbound, retailer: retailer, customer: customer, retailer_user:
              retailer_user2, created_at: Time.now - 2.days)
            create(:karix_whatsapp_message, :outbound, retailer: retailer, customer: customer_old, retailer_user:
              retailer_user2, created_at: Time.now - 8.days)
            create(:karix_whatsapp_message, :outbound, retailer: retailer, customer: customer2, retailer_user:
              retailer_user3, created_at: Time.now - 4.days)
            create(:karix_whatsapp_message, :outbound, retailer: retailer, customer: customer_old2, retailer_user:
              retailer_user, created_at: Time.now - 4.days)
            create(:karix_whatsapp_message, :outbound, retailer: retailer, customer: customer_old2, retailer_user:
              retailer_user, created_at: Time.now - 10.days)
            create_list(:karix_whatsapp_message, 3, :outbound, retailer: retailer, customer: customer, retailer_user:
              retailer_user4, created_at: Time.now - 5.days)
            create(:karix_whatsapp_message, :outbound, retailer: retailer, customer: customer_old, retailer_user:
              retailer_user4, created_at: Time.now - 4.days)
            create(:karix_whatsapp_message, :outbound, retailer: retailer, customer: customer_old2, retailer_user:
              retailer_user4, created_at: Time.now - 4.days)
          end

          it 'counts the messages sent of each agent inside the date range' do
            get retailers_total_messages_stats_path(retailer), params:
              {
                search: {
                  range: (Date.today - 6.days).to_s + ' - ' + Date.today.to_s
                }
              }

            expect(assigns(:total_agent_messages_ws)[retailer_user.id]).to eq(1)
            expect(assigns(:total_agent_messages_ws)[retailer_user2.id]).to eq(2)
            expect(assigns(:total_agent_messages_ws)[retailer_user3.id]).to eq(1)
            expect(assigns(:total_agent_messages_ws)[retailer_user4.id]).to eq(5)
          end

          it 'counts the current customers of each agent for the date range' do
            get retailers_total_messages_stats_path(retailer), params:
              {
                search: {
                  range: (Date.today - 6.days).to_s + ' - ' + Date.today.to_s
                }
              }

            expect(assigns(:total_agent_currents_ws)[retailer_user.id]).to eq(1)
            expect(assigns(:total_agent_currents_ws)[retailer_user2.id]).to be_nil
            expect(assigns(:total_agent_currents_ws)[retailer_user3.id]).to be_nil
            expect(assigns(:total_agent_currents_ws)[retailer_user4.id]).to eq(2)
          end

          it 'counts the prospects customers of each agent for the date range' do
            get retailers_total_messages_stats_path(retailer), params:
              {
                search: {
                  range: (Date.today - 6.days).to_s + ' - ' + Date.today.to_s
                }
              }

            expect(assigns(:total_agent_prospects_ws)[retailer_user.id]).to be_nil
            expect(assigns(:total_agent_prospects_ws)[retailer_user2.id]).to eq(1)
            expect(assigns(:total_agent_prospects_ws)[retailer_user3.id]).to eq(1)
            expect(assigns(:total_agent_prospects_ws)[retailer_user4.id]).to eq(1)
          end
        end

        context 'when GupShup integrated' do
          let(:retailer) { create(:retailer, :gupshup_integrated, :with_stats) }
          let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }
          let(:retailer_user2) { create(:retailer_user, :admin, retailer: retailer) }
          let(:retailer_user3) { create(:retailer_user, :supervisor, retailer: retailer) }
          let(:retailer_user4) { create(:retailer_user, :agent, retailer: retailer) }
          let(:customer_old) { create(:customer, retailer: retailer, created_at: Time.now - 10.days) }
          let(:customer_old2) { create(:customer, retailer: retailer, created_at: Time.now - 10.days) }
          let(:customer) { create(:customer, retailer: retailer) }
          let(:customer2) { create(:customer, retailer: retailer) }

          before do
            sign_in retailer_user

            create_list(:gupshup_whatsapp_message, 2, :outbound, retailer: retailer, customer: customer, retailer_user:
              retailer_user2, created_at: Time.now - 2.days)
            create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_old, retailer_user:
              retailer_user2, created_at: Time.now - 8.days)
            create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer2, retailer_user:
              retailer_user3, created_at: Time.now - 4.days)
            create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_old2, retailer_user:
              retailer_user, created_at: Time.now - 4.days)
            create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_old2, retailer_user:
              retailer_user, created_at: Time.now - 10.days)
            create_list(:gupshup_whatsapp_message, 3, :outbound, retailer: retailer, customer: customer, retailer_user:
              retailer_user4, created_at: Time.now - 5.days)
            create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_old, retailer_user:
              retailer_user4, created_at: Time.now - 4.days)
            create(:gupshup_whatsapp_message, :outbound, retailer: retailer, customer: customer_old2, retailer_user:
              retailer_user4, created_at: Time.now - 4.days)
          end

          it 'counts the messages sent of each agent inside the date range' do
            get retailers_total_messages_stats_path(retailer), params:
              {
                search: {
                  range: (Date.today - 6.days).to_s + ' - ' + Date.today.to_s
                }
              }

            expect(assigns(:total_agent_messages_ws)[retailer_user.id]).to eq(1)
            expect(assigns(:total_agent_messages_ws)[retailer_user2.id]).to eq(2)
            expect(assigns(:total_agent_messages_ws)[retailer_user3.id]).to eq(1)
            expect(assigns(:total_agent_messages_ws)[retailer_user4.id]).to eq(5)
          end

          it 'counts the current customers of each agent for the date range' do
            get retailers_total_messages_stats_path(retailer), params:
              {
                search: {
                  range: (Date.today - 6.days).to_s + ' - ' + Date.today.to_s
                }
              }

            expect(assigns(:total_agent_currents_ws)[retailer_user.id]).to eq(1)
            expect(assigns(:total_agent_currents_ws)[retailer_user2.id]).to be_nil
            expect(assigns(:total_agent_currents_ws)[retailer_user3.id]).to be_nil
            expect(assigns(:total_agent_currents_ws)[retailer_user4.id]).to eq(2)
          end

          it 'counts the prospects customers of each agent for the date range' do
            get retailers_total_messages_stats_path(retailer), params:
              {
                search: {
                  range: (Date.today - 6.days).to_s + ' - ' + Date.today.to_s
                }
              }

            expect(assigns(:total_agent_prospects_ws)[retailer_user.id]).to be_nil
            expect(assigns(:total_agent_prospects_ws)[retailer_user2.id]).to eq(1)
            expect(assigns(:total_agent_prospects_ws)[retailer_user3.id]).to eq(1)
            expect(assigns(:total_agent_prospects_ws)[retailer_user4.id]).to eq(1)
          end
        end
      end

      context 'with Messenger messages sent' do
        let(:retailer) { create(:retailer, :with_stats) }
        let(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }
        let(:retailer_user) { create(:retailer_user, :admin, retailer: retailer) }
        let(:retailer_user2) { create(:retailer_user, :admin, retailer: retailer) }
        let(:retailer_user3) { create(:retailer_user, :supervisor, retailer: retailer) }
        let(:retailer_user4) { create(:retailer_user, :agent, retailer: retailer) }
        let(:customer_old) { create(:customer, retailer: retailer, created_at: Time.now - 10.days) }
        let(:customer_old2) { create(:customer, retailer: retailer, created_at: Time.now - 10.days) }
        let(:customer) { create(:customer, retailer: retailer) }
        let(:customer2) { create(:customer, retailer: retailer) }

        before do
          sign_in retailer_user

          create_list(:facebook_message, 2, :outbound, facebook_retailer: facebook_retailer, customer:
            customer, retailer_user: retailer_user2, created_at: Time.now - 2.days)
          create(:facebook_message, :outbound, facebook_retailer: facebook_retailer, customer:
            customer_old, retailer_user: retailer_user2, created_at: Time.now - 8.days)
          create(:facebook_message, :outbound, facebook_retailer: facebook_retailer, customer:
            customer2, retailer_user: retailer_user3, created_at: Time.now - 4.days)
          create(:facebook_message, :outbound, facebook_retailer: facebook_retailer, customer:
            customer_old2, retailer_user: retailer_user, created_at: Time.now - 4.days)
          create(:facebook_message, :outbound, facebook_retailer: facebook_retailer, customer:
            customer_old2, retailer_user: retailer_user, created_at: Time.now - 10.days)
          create_list(:facebook_message, 3, :outbound, facebook_retailer: facebook_retailer, customer:
            customer, retailer_user: retailer_user4, created_at: Time.now - 5.days)
          create(:facebook_message, :outbound, facebook_retailer: facebook_retailer, customer:
            customer_old, retailer_user: retailer_user4, created_at: Time.now - 4.days)
          create(:facebook_message, :outbound, facebook_retailer: facebook_retailer, customer:
            customer_old2, retailer_user: retailer_user4, created_at: Time.now - 4.days)
        end

        it 'counts the messages sent of each agent inside the date range' do
          get retailers_total_messages_stats_path(retailer), params:
            {
              search: {
                range: (Date.today - 6.days).to_s + ' - ' + Date.today.to_s
              }
            }

          expect(assigns(:total_agent_messages_msn)[retailer_user.id]).to eq(1)
          expect(assigns(:total_agent_messages_msn)[retailer_user2.id]).to eq(2)
          expect(assigns(:total_agent_messages_msn)[retailer_user3.id]).to eq(1)
          expect(assigns(:total_agent_messages_msn)[retailer_user4.id]).to eq(5)
        end

        it 'counts the current customers of each agent for the date range' do
          get retailers_total_messages_stats_path(retailer), params:
            {
              search: {
                range: (Date.today - 6.days).to_s + ' - ' + Date.today.to_s
              }
            }

          expect(assigns(:total_agent_currents_msn)[retailer_user.id]).to eq(1)
          expect(assigns(:total_agent_currents_msn)[retailer_user2.id]).to be_nil
          expect(assigns(:total_agent_currents_msn)[retailer_user3.id]).to be_nil
          expect(assigns(:total_agent_currents_msn)[retailer_user4.id]).to eq(2)
        end

        it 'counts the prospects customers of each agent for the date range' do
          get retailers_total_messages_stats_path(retailer), params:
            {
              search: {
                range: (Date.today - 6.days).to_s + ' - ' + Date.today.to_s
              }
            }

          expect(assigns(:total_agent_prospects_msn)[retailer_user.id]).to be_nil
          expect(assigns(:total_agent_prospects_msn)[retailer_user2.id]).to eq(1)
          expect(assigns(:total_agent_prospects_msn)[retailer_user3.id]).to eq(1)
          expect(assigns(:total_agent_prospects_msn)[retailer_user4.id]).to eq(1)
        end
      end
    end

    context 'when the retailer has agents with chat' do
      context "when Karix integrated" do
        let(:retailer_karix) { create(:retailer, :karix_integrated, :with_stats) }
        let(:retailer_user_karix) { create(:retailer_user, :admin, retailer: retailer_karix) }
        let(:retailer_user_karix2) { create(:retailer_user, :agent, retailer: retailer_karix) }
        let(:customer1) { create(:customer, retailer: retailer_karix) }
        let(:customer2) { create(:customer, retailer: retailer_karix) }
        let(:customer3) { create(:customer, retailer: retailer_karix) }
        let(:customer4) { create(:customer, retailer: retailer_karix) }
        let(:customer5) { create(:customer, retailer: retailer_karix) }

        before do
          sign_in retailer_user_karix

          create(:karix_whatsapp_message, :inbound, retailer: retailer_karix, customer: customer1, retailer_user:
              retailer_user_karix, created_at: Time.now - 4.days)
          create(:karix_whatsapp_message, :outbound, :conversation, retailer: retailer_karix, customer: customer1, retailer_user:
              retailer_user_karix, created_at: Time.now - 4.days)
          create(:karix_whatsapp_message, :inbound, retailer: retailer_karix, customer: customer2, retailer_user:
              retailer_user_karix, created_at: Time.now - 5.days)
          create(:karix_whatsapp_message, :outbound, :conversation, retailer: retailer_karix, customer: customer2, retailer_user:
              retailer_user_karix, created_at: Time.now - 5.days)
          create(:karix_whatsapp_message, :inbound, retailer: retailer_karix, customer: customer3, retailer_user:
              retailer_user_karix2, created_at: Time.now - 5.days)
          create(:karix_whatsapp_message, :outbound, :conversation, retailer: retailer_karix, customer: customer3, retailer_user:
              retailer_user_karix2, created_at: Time.now - 5.days)
          create(:karix_whatsapp_message, :inbound, retailer: retailer_karix, customer: customer4, retailer_user:
              retailer_user_karix2, created_at: Time.now - 5.days)
          create(:karix_whatsapp_message, :inbound, retailer: retailer_karix, customer: customer5, retailer_user:
              retailer_user_karix, created_at: Time.now - 4.days)

          create(:karix_whatsapp_message, :inbound, retailer: retailer_karix, customer: customer4, created_at: Time.now - 5.days)

          create(:agent_customer, retailer_user: retailer_user_karix, customer: customer1, updated_at: Time.now - 4.days)
          create(:agent_customer, retailer_user: retailer_user_karix, customer: customer2, updated_at: Time.now - 4.days)
          create(:agent_customer, retailer_user: retailer_user_karix2, customer: customer3, updated_at: Time.now - 5.days)
          create(:agent_customer, retailer_user: retailer_user_karix2, customer: customer4, updated_at: Time.now - 5.days)
          create(:agent_customer, retailer_user: retailer_user_karix, customer: customer5, updated_at: Time.now - 4.days)
        end

        it 'counts the assignments and answered whatsapp chat of each agent inside the date range' do
          get retailers_total_messages_stats_path(retailer_karix), params:
            {
              search: {
                range: (Date.today - 6.days).to_s + ' - ' + Date.today.to_s
              }
            }

          expect(assigns(:total_agent_chats_assigned_ws)[retailer_user_karix.id]).to eq(3)
          expect(assigns(:total_agent_chats_answered_ws)[retailer_user_karix.id]).to eq(2)
          expect(assigns(:total_agent_chats_assigned_ws)[retailer_user_karix2.id]).to eq(2)
          expect(assigns(:total_agent_chats_answered_ws)[retailer_user_karix2.id]).to eq(1)
        end

        it "counts the assigned not answered whatsapp chats of each agent inside the date range" do
          get retailers_total_messages_stats_path(retailer_karix), params:
            {
              search: {
                range: (Date.today - 6.days).to_s + ' - ' + Date.today.to_s
              }
            }

          expect(assigns(:total_agent_chats_assigned_ws)[retailer_user_karix.id] -
            assigns(:total_agent_chats_answered_ws)[retailer_user_karix.id]).to eq(1)
          expect(assigns(:total_agent_chats_assigned_ws)[retailer_user_karix2.id] -
            assigns(:total_agent_chats_answered_ws)[retailer_user_karix2.id]).to eq(1)
        end
      end

      context "when Messenger integrated" do
        let(:retailer) { create(:retailer, :with_stats) }
        let(:facebook_retailer) { create(:facebook_retailer, retailer: retailer) }
        let(:retailer_user) { create(:retailer_user, retailer: retailer) }
        let(:customer1) { create(:customer, retailer: retailer) }
        let(:customer2) { create(:customer, retailer: retailer) }
        let(:customer3) { create(:customer, retailer: retailer) }

        before do
          sign_in retailer_user

          create_list(:facebook_message, 3, :inbound, facebook_retailer: facebook_retailer, retailer_user:
            retailer_user, customer: customer1, created_at: Time.now - 19.hours)
          create_list(:facebook_message, 3, :inbound, facebook_retailer: facebook_retailer, retailer_user:
            retailer_user, customer: customer2, created_at: Time.now - 13.hours)
          create_list(:facebook_message, 2, :outbound, facebook_retailer: facebook_retailer, retailer_user:
            retailer_user, customer: customer1, created_at: Time.now - 20.hours)
          create_list(:facebook_message, 2, :outbound, facebook_retailer: facebook_retailer, retailer_user:
            retailer_user, customer: customer2, created_at: Time.now)
          create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, retailer_user:
            retailer_user, customer: customer3, created_at: Time.now)

          # Se eliminan las asignaciones creadas automaticamente porque no concuerdan las fechas con las pruebas
          retailer_user.agent_customers.destroy_all
          create(:agent_customer, retailer_user: retailer_user, customer: customer1, updated_at: Time.now - 2.hours)
          create(:agent_customer, retailer_user: retailer_user, customer: customer2, updated_at: Time.now - 12.hours)
          create(:agent_customer, retailer_user: retailer_user, customer: customer3, updated_at: Time.now - 19.hours)
        end

        it 'counts the assignments and answered messenger chat of each agent inside the date range' do
          get retailers_total_messages_stats_path(retailer), params:
            {
              search: {
                range: (Date.today - 5.days).to_s + ' - ' + Date.today.to_s
              }
            }

          expect(assigns(:total_agent_chats_assigned_msn)[retailer_user.id]).to eq(3)
          expect(assigns(:total_agent_chats_answered_msn)[retailer_user.id]).to eq(2)
        end

        it 'counts the assigned not answered messenger chats of each agent inside the date range' do
          get retailers_total_messages_stats_path(retailer), params:
            {
              search: {
                range: (Date.today - 5.days).to_s + ' - ' + Date.today.to_s
              }
            }

          expect(assigns(:total_agent_chats_assigned_msn)[retailer_user.id] -
            assigns(:total_agent_chats_answered_msn)[retailer_user.id]).to eq(1)
        end
      end
    end
  end
end
