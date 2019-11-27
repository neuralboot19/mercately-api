class Api::V1::CustomersController < ApplicationController
  include CurrentRetailer
  before_action :authenticate_retailer_user!
  before_action :set_customer, except: :index

  def index
    @customers = current_retailer.customers.facebook_customers.active
    render status: 200, json: {customers: @customers}
  end

  def messages
    render status: 200, json: {messages: @customer.facebook_messages}
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end
end
