require 'rails_helper'

RSpec.describe Retailers::Api::V1::CustomersController, type: :request do
  include ApiDoc::V1::Customer::Api

  let!(:retailer) { create(:retailer, name: 'Test Connection') }
  let(:tag) { create(:tag, retailer: retailer, tag: 'Test tag' ) }
  let!(:crf){ create(:customer_related_field, retailer: retailer ) }

  let(:retailer_user) do
    create(:retailer_user, retailer: retailer, email: 'agent@example.com', first_name: 'Agent', last_name:
      'Example')
  end

  # Generating credentials for the retailer
  let(:slug) { retailer_user.retailer.slug }
  let(:api_key) { retailer_user.retailer.generate_api_key }

  describe 'GET #index' do
    include ApiDoc::V1::Customer::Index
    let(:cus) { create(:customer, retailer: retailer, created_at: Time.now - 8.days) }
    let!(:customer_tag){ create(:customer_tag, tag: tag, customer: cus ) }
    let!(:crd){ create(:customer_related_datum, customer_related_field: crf, customer: cus, data: 'Test Field' ) }

    it "returns all customers", :dox do
      get "/retailers/api/v1/customers", headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }, params: {
          page: 1
        }
      json_response = JSON.parse(response.body)
      expect(response.content_type).to eq "application/json"
      expect(json_response["results"]).to eq(1)
      expect(json_response["total_pages"]).to eq(1)
      expect(json_response["customers"].class).to eq(Array)
    end
  end

  describe 'GET #show' do
    include ApiDoc::V1::Customer::Show
    let(:cus) { create(:customer, retailer: retailer, created_at: Time.now - 8.days) }

    it "returns a customer", :dox do

      get "/retailers/api/v1/customers/#{cus.web_id}", headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }
      json_response = JSON.parse(response.body)
      expect(response.content_type).to eq "application/json"
      expect(json_response["message"]).to eq("Customer found successfully")
    end
  end

  describe 'Post #create' do
    include ApiDoc::V1::Customer::Create
    let(:cus) { create(:customer, retailer: retailer, created_at: Time.now - 8.days) }
    let(:tag){ create(:tag, tag: 'Test tag', retailer: retailer ) }
    let(:params) do
      { customer: {
          first_name: 'Juan',
          last_name: 'Campos',
          email: 'juan@email.com',
          phone: '+12036534789',
          notes: 'New notes',
          address: 'Calle 5',
          city: 'Fort Worth',
          state: 'TX',
          zip_code: '76106',
          tags: [
            {
              name: tag.tag,
              value: true
            }
          ]
        }
      }
    end

    it "creates a customer", :dox do
      post "/retailers/api/v1/customers", headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }, params: params, as: :json

      json_response = JSON.parse(response.body)
      expect(response.content_type).to eq "application/json"
      expect(json_response["message"]).to eq('Customer created successfully')
    end
  end

  describe 'PUT #update' do
    include ApiDoc::V1::Customer::Update
    let(:cus) { create(:customer, retailer: retailer, created_at: Time.now - 8.days) }

    it "updates a customer", :dox do
      put "/retailers/api/v1/customers/#{cus.web_id}", headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }, params: { customer: {
          first_name: 'Juan',
          last_name: 'Campos',
          email: 'juan@email.com',
          phone: '+12036534789',
          notes: 'New notes',
          address: 'Calle 5',
          city: 'Fort Worth',
          state: 'TX',
          zip_code: '76106'
        }
      }, as: :json

      json_response = JSON.parse(response.body)
      expect(response.content_type).to eq "application/json"
      expect(json_response["message"]).to eq("Customer updated successfully")
    end

    context 'when an agent_id is sent' do
      it 'assigns the customer to an agent', :dox do
        expect {
          put "/retailers/api/v1/customers/#{cus.web_id}", headers:
            {
              'Slug': slug,
              'Api-Key': api_key
            }, params: { customer: {
              first_name: 'Juan',
              last_name: 'Campos',
              email: 'juan@email.com',
              phone: '+12036534789',
              notes: 'New notes',
              address: 'Calle 5',
              city: 'Fort Worth',
              state: 'TX',
              zip_code: '76106',
              agent_id: retailer_user.id
            }
          }, as: :json
        }.to change { AgentCustomer.count }.by(1)

        json_response = JSON.parse(response.body)
        expect(response.content_type).to eq "application/json"
        expect(json_response["message"]).to eq("Customer updated successfully")
      end
    end

    context 'when tags are sent.' do
      let(:tag){ create(:tag, tag: 'Test Tag', retailer: retailer ) }
      let(:tag2){ create(:tag, tag: 'Test Tag 2', retailer: retailer ) }
      let(:customer_tag){ create(:customer_tag, tag: tag2, customer: cus ) }
      let(:params) do
        {
          customer: {
            first_name: 'Juan',
            last_name: 'Campos',
            email: 'juan@email.com',
            phone: '+12036534789',
            notes: 'New notes',
            address: 'Calle 5',
            city: 'Fort Worth',
            state: 'TX',
            zip_code: '76106',
            agent_id: retailer_user.id,
            tags: [
              {
                name: tag.tag,
                value: true
              }
            ]
          }
        }
      end

      it 'assigns the customer a tag', :dox do

        put "/retailers/api/v1/customers/#{cus.web_id}", headers:
          {
            'Slug': slug,
            'Api-Key': api_key
          }, params: params, as: :json

        json_response = JSON.parse(response.body)
        expect(response.content_type).to eq "application/json"
        expect(json_response["message"]).to eq("Customer updated successfully")
        expect(cus.tags.count).to eq(1)
      end

      it 'remove tag from customer', :dox do

        expect {
          put "/retailers/api/v1/customers/#{cus.web_id}", headers:
            {
              'Slug': slug,
              'Api-Key': api_key
            }, params: { customer: {
              first_name: 'Juan',
              last_name: 'Campos',
              email: 'juan@email.com',
              phone: '+12036534789',
              notes: 'New notes',
              address: 'Calle 5',
              city: 'Fort Worth',
              state: 'TX',
              zip_code: '76106',
              agent_id: retailer_user.id,
              tags: [
                {
                  name: tag2.tag,
                  value: false
                }
              ]
            }
          }, as: :json
        }.to change { AgentCustomer.count }.by(1)

        json_response = JSON.parse(response.body)
        expect(response.content_type).to eq "application/json"
        expect(json_response["message"]).to eq("Customer updated successfully")
        expect(cus.tags.count).to eq(0)
      end
    end
  end
end
