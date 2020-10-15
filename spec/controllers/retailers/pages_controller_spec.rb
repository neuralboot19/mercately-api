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

    it 'does NOT create a flash message if first name and last name present in the retailer user' do
      retailer_user.update_attributes(
        first_name: 'Retailer First Name',
        last_name: 'Retailer Last Name'
      )

      get :dashboard, params: { slug: retailer_user.retailer.slug }
      expect(flash[:alert]).to_not be_present
    end

    it 'returns a start_date and end_date' do
      get :dashboard, params: { slug: retailer_user.retailer.slug , search: { range: "#{Time.now.strftime("%d/%m/%Y")} - #{(Time.now + 5.days).strftime("%d/%m/%Y")}"} }

      expect(assigns(:start_date)).to eq(Time.now.strftime("%d/%m/%Y"))
      expect(assigns(:end_date)).to eq((Time.now + 5.days).strftime("%d/%m/%Y"))
    end
  end

  describe "before_action #validate_payment_plan" do
    it 'redirects to retailers_payment_plans_path if payment plan not active' do
      retailer_user.retailer.payment_plan.update!(status: 'inactive')
      get :dashboard, params: { slug: retailer_user.retailer.slug }
      expect(response).to redirect_to(
        retailers_payment_plans_path(retailer_user.retailer)
      )
    end
  end
end
