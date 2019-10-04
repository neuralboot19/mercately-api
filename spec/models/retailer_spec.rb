require 'rails_helper'

RSpec.describe Retailer, type: :model do
  subject(:retailer) { build(:retailer) }

  describe 'enums' do
    it { is_expected.to define_enum_for(:id_type).with_values(%i[cedula pasaporte ruc]) }
  end

  describe 'associations' do
    it { is_expected.to have_one(:meli_retailer) }
    it { is_expected.to have_one(:retailer_user) }

    it { is_expected.to have_many(:products) }
    it { is_expected.to have_many(:customers) }
    it { is_expected.to have_many(:retailer_users) }
    it { is_expected.to have_many(:templates) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  it 'after save a name generates a slug' do
    expect(retailer.slug).to be_nil
    retailer.save
    expect(retailer.slug).not_to be_nil
  end

  context 'when there are retailers with the same name' do
    let(:retailer_2) { create(:retailer, name: retailer.name) }

    it 'generates a slug with the retailer id' do
      retailer.save
      expect(retailer_2.slug).not_to eq retailer.slug
      expect(retailer_2.slug).to eq "#{retailer_2.name}-#{retailer_2.id}".parameterize
    end
  end

  describe '#update_meli_access_token' do
    subject(:retailer) { create(:retailer) }
    let!(:meli_retailer) { create(:meli_retailer, retailer: retailer) }
    let!(:access_token) { meli_retailer.access_token }

    context 'when meli_retailer.meli_token_updated_at is more than current hour - 4' do
      it 'does not update the access_token' do
        meli_retailer.meli_token_updated_at = Time.now - 6.hours
        retailer.update_meli_access_token
        expect(meli_retailer.access_token).to eq nil
      end
    end

    context 'when meli_retailer.meli_token_updated_at is minor than current hour - 4' do
      it 'updates the access_token' do
        retailer.update_meli_access_token
        expect(meli_retailer.access_token).to eq access_token
      end
    end
  end

  describe '#unread_messages' do
    let(:customer) { create(:customer, retailer: retailer) }
    let(:order) { create(:order, customer: customer) }
    let!(:unread_messages) { create_list(:message, 5, order: order, customer: customer) }
    let!(:readed_messages) { create_list(:message, 3, :readed, order: order, customer: customer) }

    it 'returns only the unreaded messages' do
      expect(retailer.unread_messages.count).to eq 5
    end
  end

  describe '#unread_questions' do
    let(:product) { create(:product, retailer: retailer) }
    let(:customer) { create(:customer, retailer: retailer) }
    let!(:unread_questions) { create_list(:question, 5, product: product, customer: customer) }
    let!(:readed_questions) { create_list(:question, 3, :readed, product: product, customer: customer) }

    it 'returns only the unreaded questions' do
      expect(retailer.unread_questions.count).to eq 5
    end
  end
end
