require 'rails_helper'

RSpec.describe Category, type: :model do
  subject(:category) { create(:category) }

  let(:retailer) { create(:retailer) }
  let(:order1) { create(:order, status: 'success') }
  let(:order2) { create(:order, status: 'success') }
  let(:product1) { create(:product, retailer: retailer, category: category) }
  let(:product2) { create(:product, retailer: retailer, category: category) }

  describe 'associations' do
    it { is_expected.to have_many(:products) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:meli_id) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(%i[active inactive]) }
  end

  describe '#required_product_attributes' do
    it 'returns the required product attributes' do
      expect(category.required_product_attributes).to eq %w[BRAND MODEL COLOR]
    end
  end

  describe '#clean_template_variations' do
    let(:result) do
      [{ 'attribute_group_id' => 'OTHERS',
         'attribute_group_name' => 'Otros',
         'hierarchy' => 'PARENT_PK',
         'id' => 'BRAND',
         'name' => 'Marca',
         'relevance' => 1,
         'tags' => { 'new_required' => true },
         'value_max_length' => 255,
         'value_type' => 'string' },
       { 'attribute_group_id' => 'OTHERS',
         'attribute_group_name' => 'Otros',
         'hierarchy' => 'PARENT_PK',
         'id' => 'MODEL',
         'name' => 'Modelo',
         'relevance' => 1,
         'tags' => { 'catalog_required' => true },
         'value_max_length' => 255,
         'value_type' => 'string' },
       { 'attribute_group_id' => 'OTHERS',
         'attribute_group_name' => 'Otros',
         'hierarchy' => 'CHILD_PK',
         'id' => 'COLOR',
         'name' => 'Color',
         'relevance' => 1,
         'tags' => { 'catalog_required' => true, 'defines_picture' => true },
         'value_max_length' => 255,
         'value_type' => 'string',
         'values' =>
    [{ 'id' => '52019', 'name' => 'Verde oscuro' },
     { 'id' => '283160', 'name' => 'Turquesa' },
     { 'id' => '52022', 'name' => 'Agua' },
     { 'id' => '283162', 'name' => '??ndigo' },
     { 'id' => '52036', 'name' => 'Lavanda' },
     { 'id' => '283163', 'name' => 'Rosa chicle' },
     { 'id' => '51998', 'name' => 'Bord??' },
     { 'id' => '52003', 'name' => 'Piel' },
     { 'id' => '52055', 'name' => 'Blanco' },
     { 'id' => '283161', 'name' => 'Azul marino' },
     { 'id' => '52008', 'name' => 'Crema' },
     { 'id' => '52045', 'name' => 'Rosa p??lido' },
     { 'id' => '283153', 'name' => 'Suela' },
     { 'id' => '283150', 'name' => 'Naranja claro' },
     { 'id' => '52028', 'name' => 'Azul' },
     { 'id' => '52043', 'name' => 'Rosa claro' },
     { 'id' => '283148', 'name' => 'Coral claro' },
     { 'id' => '283149', 'name' => 'Coral' },
     { 'id' => '52021', 'name' => 'Celeste' },
     { 'id' => '52031', 'name' => 'Azul acero' },
     { 'id' => '283156', 'name' => 'Caqui' },
     { 'id' => '52001', 'name' => 'Beige' },
     { 'id' => '51993', 'name' => 'Rojo' },
     { 'id' => '51996', 'name' => 'Terracota' },
     { 'id' => '283165', 'name' => 'Gris' },
     { 'id' => '52035', 'name' => 'Violeta' },
     { 'id' => '283154', 'name' => 'Marr??n claro' },
     { 'id' => '52049', 'name' => 'Negro' },
     { 'id' => '283155', 'name' => 'Marr??n oscuro' },
     { 'id' => '52053', 'name' => 'Plateado' },
     { 'id' => '52047', 'name' => 'Violeta oscuro' },
     { 'id' => '51994', 'name' => 'Rosa' },
     { 'id' => '52007', 'name' => 'Amarillo' },
     { 'id' => '283157', 'name' => 'Verde lima' },
     { 'id' => '52012', 'name' => 'Dorado oscuro' },
     { 'id' => '52015', 'name' => 'Verde claro' },
     { 'id' => '283151', 'name' => 'Naranja oscuro' },
     { 'id' => '52024', 'name' => 'Azul petr??leo' },
     { 'id' => '52051', 'name' => 'Gris oscuro' },
     { 'id' => '283152', 'name' => 'Chocolate' },
     { 'id' => '52014', 'name' => 'Verde' },
     { 'id' => '283164', 'name' => 'Dorado' },
     { 'id' => '52000', 'name' => 'Naranja' },
     { 'id' => '52033', 'name' => 'Azul oscuro' },
     { 'id' => '52010', 'name' => 'Ocre' },
     { 'id' => '283158', 'name' => 'Verde musgo' },
     { 'id' => '52005', 'name' => 'Marr??n' },
     { 'id' => '52038', 'name' => 'Lila' },
     { 'id' => '52042', 'name' => 'Fucsia' },
     { 'id' => '338779', 'name' => 'Cian' },
     { 'id' => '52029', 'name' => 'Azul claro' }] }]
    end

    it 'returns the clean template variations' do
      expect(category.clean_template_variations).to eq result
    end
  end

  describe '#total_products' do
    let(:retailer) { create(:retailer) }

    before do
      create_list(:product, 5, retailer: retailer, category: category)
    end

    it 'returns the quantity of products of the category for the retailer' do
      expect(category.total_products(retailer)).to eq(5)
    end
  end

  describe '#total_products_sold' do
    let!(:order_item1) { create(:order_item, order: order1, product: product1, quantity: 3) }
    let!(:order_item2) { create(:order_item, order: order2, product: product2, quantity: 2) }

    it 'returns the quantity of sold products of the category for the retailer' do
      expect(category.total_products_sold(retailer, 1.day.ago, Time.now)).to eq(5)
    end
  end

  describe '#earnings' do
    let!(:order_item1) { create(:order_item, order: order1, product: product1, quantity: 3, unit_price: 25) }
    let!(:order_item2) { create(:order_item, order: order2, product: product2, quantity: 2, unit_price: 5.5) }

    it 'returns the profit of the category for the retailer' do
      expect(category.earnings(retailer, 1.day.ago, Time.now)).to eq(86)
    end
  end
end
