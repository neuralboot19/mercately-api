require 'rails_helper'

RSpec.describe 'StatsController', type: :request do
  let(:retailer) { create(:retailer) }
  let(:retailer_user) { create(:retailer_user, retailer: retailer) }

  describe '#index' do
    context 'when the retailer is not logged in' do
      it 'redirects to login page' do
        get retailers_stats_path(retailer)

        expect(response).to redirect_to('/login')
      end
    end

    context 'when the retailer is logged in' do
      it 'responses ok' do
        sign_in retailer_user
        get retailers_stats_path(retailer)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe '#total_messages_stats' do
    let(:customer_old) { create(:customer, retailer: retailer, created_at: Date.today - 8.days) }
    let(:customer_old2) { create(:customer, retailer: retailer, created_at: Date.today - 8.days) }
    let(:customer) { create(:customer, retailer: retailer) }
    let(:customer2) { create(:customer, retailer: retailer) }

    context 'when the retailer is whatsapp integrated' do
      context 'with karix integrated' do
        let(:retailer) { create(:retailer, :karix_integrated, :with_stats) }
        let(:retailer_user) { create(:retailer_user, retailer: retailer) }

        before do
          sign_in retailer_user
        end

        context 'when a date range is not passed' do
          before do
            create_list(:karix_whatsapp_message, 2, :inbound, retailer: retailer, customer: customer)
            create_list(:karix_whatsapp_message, 2, :inbound, retailer: retailer, customer: customer_old)
            create(:karix_whatsapp_message, :inbound, retailer: retailer, customer: customer2, created_at:
              Date.today - 8.days)

            create_list(:karix_whatsapp_message, 3, :outbound, retailer: retailer)
            create_list(:karix_whatsapp_message, 2, :outbound, retailer: retailer, created_at: Date.today - 8.days)
          end

          it 'loads the total inbound and outbound messages for the last 5 days' do
            get retailers_total_messages_stats_path(retailer)

            expect(assigns(:total_inbound_ws)).to eq(4)
            expect(assigns(:total_outbound_ws)).to eq(3)
            expect(assigns(:ws_prospects)).to eq(1)
            expect(assigns(:ws_currents)).to eq(1)
          end
        end

        context 'when a date range is passed' do
          before do
            create_list(:karix_whatsapp_message, 2, :inbound, retailer: retailer, customer: customer)
            create_list(:karix_whatsapp_message, 2, :inbound, retailer: retailer, customer: customer_old)
            create(:karix_whatsapp_message, :inbound, retailer: retailer, customer: customer2, created_at:
              Date.today - 8.days)

            create_list(:karix_whatsapp_message, 3, :outbound, retailer: retailer)
            create_list(:karix_whatsapp_message, 2, :outbound, retailer: retailer, created_at: Date.today - 8.days)
          end

          it 'loads the total inbound and outbound messages for the date range' do
            get retailers_total_messages_stats_path(retailer), params:
              {
                search: {
                  range: (Date.today - 9.days).to_s + ' - ' + (Date.today - 1.days).to_s
                }
              }

            expect(assigns(:total_inbound_ws)).to eq(1)
            expect(assigns(:total_outbound_ws)).to eq(2)
            expect(assigns(:ws_prospects)).to eq(0)
            expect(assigns(:ws_currents)).to eq(1)
          end
        end
      end

      context 'with GupShup integrated' do
        let(:retailer) { create(:retailer, :gupshup_integrated, :with_stats) }
        let(:retailer_user) { create(:retailer_user, retailer: retailer) }

        before do
          sign_in retailer_user
        end

        context 'when a date range is not passed' do
          before do
            create_list(:gupshup_whatsapp_message, 2, :inbound, retailer: retailer, customer: customer_old)
            create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer_old2, created_at:
              Date.today - 8.days)

            create_list(:gupshup_whatsapp_message, 3, :outbound, retailer: retailer)
            create_list(:gupshup_whatsapp_message, 2, :outbound, retailer: retailer, created_at: Date.today - 8.days)
          end

          it 'loads the total inbound and outbound messages for the last 5 days' do
            get retailers_total_messages_stats_path(retailer)

            expect(assigns(:total_inbound_ws)).to eq(2)
            expect(assigns(:total_outbound_ws)).to eq(3)
            expect(assigns(:ws_prospects)).to eq(0)
            expect(assigns(:ws_currents)).to eq(1)
          end
        end

        context 'when a date range is passed' do
          before do
            create_list(:gupshup_whatsapp_message, 2, :inbound, retailer: retailer, customer: customer_old)
            create(:gupshup_whatsapp_message, :inbound, retailer: retailer, customer: customer_old2, created_at:
              Date.today - 8.days)

            create_list(:gupshup_whatsapp_message, 3, :outbound, retailer: retailer)
            create_list(:gupshup_whatsapp_message, 2, :outbound, retailer: retailer, created_at: Date.today - 8.days)
          end

          it 'loads the total inbound and outbound messages for the date range' do
            get retailers_total_messages_stats_path(retailer), params:
              {
                search: {
                  range: (Date.today - 9.days).to_s + ' - ' + (Date.today - 1.days).to_s
                }
              }

            expect(assigns(:total_inbound_ws)).to eq(1)
            expect(assigns(:total_outbound_ws)).to eq(2)
            expect(assigns(:ws_prospects)).to eq(1)
            expect(assigns(:ws_currents)).to eq(0)
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
      end

      context 'when a date range is not passed' do
        before do
          create_list(:facebook_message, 2, :inbound, facebook_retailer: facebook_retailer, customer: customer_old2)
          create_list(:facebook_message, 2, :inbound, facebook_retailer: facebook_retailer, customer: customer)
          create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer2)
          create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer, created_at:
            Date.today - 8.days)
          create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer_old, created_at:
            Date.today - 8.days)

          create_list(:facebook_message, 3, :outbound, facebook_retailer: facebook_retailer)
          create_list(:facebook_message, 2, :outbound, facebook_retailer: facebook_retailer, created_at:
            Date.today - 8.days)
        end

        it 'loads the total inbound and outbound messages for the last 5 days' do
          get retailers_total_messages_stats_path(retailer)

          expect(assigns(:total_inbound_msn)).to eq(5)
          expect(assigns(:total_outbound_msn)).to eq(3)
          expect(assigns(:msn_prospects)).to eq(2)
          expect(assigns(:msn_currents)).to eq(1)
        end
      end

      context 'when a date range is passed' do
        before do
          create_list(:facebook_message, 2, :inbound, facebook_retailer: facebook_retailer, customer: customer_old2)
          create_list(:facebook_message, 2, :inbound, facebook_retailer: facebook_retailer, customer: customer)
          create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer2)
          create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer, created_at:
            Date.today - 8.days)
          create(:facebook_message, :inbound, facebook_retailer: facebook_retailer, customer: customer_old, created_at:
            Date.today - 8.days)

          create_list(:facebook_message, 3, :outbound, facebook_retailer: facebook_retailer)
          create_list(:facebook_message, 2, :outbound, facebook_retailer: facebook_retailer, created_at:
            Date.today - 8.days)
        end

        it 'loads the total inbound and outbound messages for the date range' do
          get retailers_total_messages_stats_path(retailer), params:
            {
              search: {
                range: (Date.today - 9.days).to_s + ' - ' + (Date.today - 1.days).to_s
              }
            }

          expect(assigns(:total_inbound_msn)).to eq(2)
          expect(assigns(:total_outbound_msn)).to eq(2)
          expect(assigns(:msn_prospects)).to eq(1)
          expect(assigns(:msn_currents)).to eq(1)
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
  end

  describe '#current_time_zone' do
    before do
      sign_in retailer_user
    end

    context 'when the requests comes from Argentina' do
      it 'returns a timezone equal to Argentina to query the data' do
        allow(Time).to receive(:now).and_return('2020-09-10 13:40:19 -0300'.to_time)

        get retailers_total_messages_stats_path(retailer)

        expect(Time.zone.name).to eq('Brasilia')
      end
    end

    context 'when the requests comes from Venezuela' do
      it 'returns a timezone equal to Venezuela to query the data' do
        allow(Time).to receive(:now).and_return('2020-09-10 13:40:19 -0400'.to_time)

        get retailers_total_messages_stats_path(retailer)

        expect(Time.zone.name).to eq('Caracas')
      end
    end

    context 'when the requests comes from Ecuador' do
      it 'returns a timezone equal to Ecuador to query the data' do
        allow(Time).to receive(:now).and_return('2020-09-10 13:40:19 -0500'.to_time)

        get retailers_total_messages_stats_path(retailer)

        expect(Time.zone.name).to eq('Bogota')
      end
    end
  end
end
