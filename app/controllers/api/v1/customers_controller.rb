class Api::V1::CustomersController < ApplicationController
  def index
    # @q = current_retailer.customers.facebook_customers.active.ransack(params[:q])
    # @customers = @q.result.page(params[:page])
    byebug
    users = {
      customers: [
        {
          psid: '298374',
          first_name: 'Daniel',
          last_name: 'Ortin',
          message_data: {
            text: 'Hello World',
            created_at: 1574883680977
          }
        },
        {
          psid: '92834729847',
          first_name: 'Johnmer',
          last_name: 'Bencomo',
          message_data: {
            text: 'Message not readed',
            created_at: 1574883680977
          }
        },
        {
          psid: '28911928',
          first_name: 'Henry',
          last_name: 'Remache',
          message_data: {
            text: 'Hello World',
            created_at: 1574883680977
          }
        }
      ]
    }
    render status: 200, json: users
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end
end
