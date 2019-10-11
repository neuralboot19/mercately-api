require 'rails_helper'
require 'vcr'

RSpec.describe MercadoLibre::Categories, vcr: true do
  let(:retailer) { create(:retailer) }
  subject(:categories_service) { MercadoLibre::Categories.new(retailer) }

  describe '#import_category' do
    it 'imports the category' do
      VCR.use_cassette('categories/category') do
        expect{ categories_service.import_category('MEC5725') }.to change(Category, :count).by(1)
      end
    end

    context 'when category is a category child' do
      it 'imports the category and category root' do
        VCR.use_cassette('categories/category_with_roots') do
          expect{ categories_service.import_category('MEC1747') }.to change(Category, :count).by(2)
        end
      end
    end
  end

  describe '#prepare_request' do
    let(:url) { categories_service.api.get_category_url('MEC1747') }
    let(:response) { categories_service.prepare_request(url) }

    it 'returns the response from ML' do
      VCR.use_cassette('categories/category_with_roots') do
        expect(response).to include('id').and(include('name'))
      end
    end

    it 'returns the root category from ML' do
      VCR.use_cassette('categories/category_with_roots') do
        expect(response).to include('path_from_root')
        expect(response['path_from_root'][0]).to include('id').and(include('name'))
      end
    end
  end
end
