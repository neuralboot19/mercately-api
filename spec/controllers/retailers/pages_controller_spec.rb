require 'rails_helper'

RSpec.describe Retailers::PagesController, type: :controller do
  let(:retailer_user) { create(:retailer_user, :with_retailer, first_name: '', last_name: '' ) }

  before do
    sign_in retailer_user
  end

  describe '#dashboard' do
    it 'creates a flash message if no first name neither last name present in the retailer user' do
      get :dashboard, params: { slug: retailer_user.retailer.slug }
      expect(flash[:alert]).to be_present
    end

    it 'creates a flash message if no first name present in the retailer user' do
      retailer_user.update_attributes(
        last_name: 'Retailer Last Name'
      )

      get :dashboard, params: { slug: retailer_user.retailer.slug }
      expect(flash[:alert]).to be_present
    end

    it 'creates a flash message if no last name present in the retailer user' do
      retailer_user.update_attributes(
        first_name: 'Retailer First Name'
      )

      get :dashboard, params: { slug: retailer_user.retailer.slug }
      expect(flash[:alert]).to be_present
    end

    it 'NOT creates a flash message if first name and last name present in the retailer user' do
      retailer_user.update_attributes(
        first_name: 'Retailer First Name',
        last_name: 'Retailer Last Name'
      )

      get :dashboard, params: { slug: retailer_user.retailer.slug }
      expect(flash[:alert]).to_not be_present
    end
  end
end
