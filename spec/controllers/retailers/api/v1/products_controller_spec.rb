require 'rails_helper'

RSpec.describe Retailers::Api::V1::ProductsController, type: :request do
  include ApiDoc::V1::Product::Api

  let!(:retailer) { create(:retailer, name: 'Test Connection') }
  let(:retailer_user) do
    create(:retailer_user, retailer: retailer, email: 'agent@example.com', first_name: 'Agent', last_name:
      'Example')
  end

  # Generating credentials for the retailer
  let(:slug) { retailer_user.retailer.slug }
  let(:api_key) { retailer_user.retailer.generate_api_key }

  describe 'GET #index' do
    include ApiDoc::V1::Product::Index
    let!(:product) do
      create(:product, retailer: retailer, title: 'Product 1', price: 10.5, available_quantity: 5,
        description: 'Product description 1', status: 'archived', created_at: Time.now - 8.days)
    end

    let!(:product2) do
      create(:product, retailer: retailer, title: 'Product 2', price: 5, available_quantity: 2,
        description: 'Product description 2', created_at: Time.now - 2.days)
    end

    it 'returns all products', :dox do
      get '/retailers/api/v1/products', headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }, params: {
          page: 1
        }

      json_response = JSON.parse(response.body)
      expect(response.content_type).to eq('application/json')
      expect(json_response['total']).to eq(2)
      expect(json_response['total_pages']).to eq(1)
      expect(json_response['products'].class).to eq(Array)
    end
  end

  describe 'GET #show' do
    include ApiDoc::V1::Product::Show
    let(:product) do
      create(:product, retailer: retailer, title: 'Product 1', price: 10.5, available_quantity: 5,
        description: 'Product description 1')
    end

    it 'returns a product', :dox do
      get "/retailers/api/v1/products/#{product.web_id}", headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }

      json_response = JSON.parse(response.body)
      expect(response.content_type).to eq('application/json')
      expect(json_response['message']).to eq('Product found successfully')
    end
  end

  describe 'POST #create' do
    include ApiDoc::V1::Product::Create

    context 'when some mandatory field is not sent (title, price)' do
      let(:params) do
        { product: {
            title: 'Product title',
            available_quantity: 5
          }
        }
      end

      it 'returns 422 - Unprocessable Entity', :dox do
        post '/retailers/api/v1/products', headers:
          {
            'Slug': slug,
            'Api-Key': api_key
          }, params: params, as: :json

        json_response = JSON.parse(response.body)
        expect(response.content_type).to eq('application/json')
        expect(json_response['message']).to eq('Error creating product')
      end
    end

    context 'when more than three images urls are sent' do
      let(:params) do
        { product: {
            title: 'Product title',
            price: 100,
            available_quantity: 5,
            image_urls: [
              'https://mercately.com/images/example.jpg',
              'https://mercately.com/images/example2.png',
              'https://mercately.com/images/example3.jpg',
              'https://mercately.com/images/example4.png'
            ]
          }
        }
      end

      it 'returns 400 - Bad Request', :dox do
        post '/retailers/api/v1/products', headers:
          {
            'Slug': slug,
            'Api-Key': api_key
          }, params: params, as: :json

        json_response = JSON.parse(response.body)
        expect(response.content_type).to eq('application/json')
        expect(json_response['message']).to eq('Maximum three (3) images allowed')
      end
    end

    context 'when all data is good' do
      before do
        allow_any_instance_of(Product).to receive(:attach_image).and_return(true)
      end

      let(:params) do
        { product: {
            title: 'Product title',
            price: 100,
            available_quantity: 5,
            url: 'https://mercately.com/products/product_example',
            description: 'Description example',
            image_urls: [
              'https://mercately.com/images/example.jpg',
              'https://mercately.com/images/example2.png'
            ]
          }
        }
      end

      it 'creates the product successfully', :dox do
        post '/retailers/api/v1/products', headers:
          {
            'Slug': slug,
            'Api-Key': api_key
          }, params: params, as: :json

        json_response = JSON.parse(response.body)
        expect(response.content_type).to eq('application/json')
        expect(json_response['message']).to eq('Product created successfully')
      end
    end
  end

  describe 'PUT #update' do
    include ApiDoc::V1::Product::Update

    before do
      allow_any_instance_of(Product).to receive(:attach_image).and_return(true)
    end

    let(:product) do
      create(:product, retailer: retailer, title: 'Product 1', price: 10.5, available_quantity: 5,
        description: 'Product description 1')
    end

    let(:params) do
      { product: {
          title: 'Product title',
          price: 100,
          available_quantity: 7,
          url: 'https://mercately.com/products/product_example',
          description: 'Description example'
        }
      }
    end

    it 'updates the product successfully', :dox do
      put "/retailers/api/v1/products/#{product.web_id}", headers:
        {
          'Slug': slug,
          'Api-Key': api_key
        }, params: params, as: :json

      json_response = JSON.parse(response.body)
      expect(response.content_type).to eq('application/json')
      expect(json_response['message']).to eq('Product updated successfully')
    end

    context 'when the product is active' do
      let(:params) do
        { product: {
            status: 'archived'
          }
        }
      end

      it 'archives the product', :dox do
        put "/retailers/api/v1/products/#{product.web_id}", headers:
          {
            'Slug': slug,
            'Api-Key': api_key
          }, params: params, as: :json

        json_response = JSON.parse(response.body)
        expect(response.content_type).to eq('application/json')
        expect(product.reload.status).to eq('archived')
        expect(json_response['message']).to eq('Product updated successfully')
      end
    end

    context 'when the product is archived' do
      let(:product) do
        create(:product, retailer: retailer, title: 'Product 1', price: 10.5, available_quantity: 5,
          description: 'Product description 1', status: 'archived')
      end

      let(:params) do
        { product: {
            status: 'active'
          }
        }
      end

      it 'activates the product', :dox do
        put "/retailers/api/v1/products/#{product.web_id}", headers:
          {
            'Slug': slug,
            'Api-Key': api_key
          }, params: params, as: :json

        json_response = JSON.parse(response.body)
        expect(response.content_type).to eq('application/json')
        expect(product.reload.status).to eq('active')
        expect(json_response['message']).to eq('Product updated successfully')
      end
    end
  end
end
