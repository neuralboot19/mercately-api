module Retailers::Api::V1
  class CustomersController < Retailers::Api::V1::ApiController
    before_action :find_customer, only: :update

    def update
      if @customer.update(customer_attributes)
        assign_agent(@customer, params)
        render status: 200, json: {
          message: "Customer updated successfully"
        }
      else
        render status: 302, json: {
          errors: @customer.errors.full_messages
        }
      end
    end

    private

      def find_customer
        @customer = current_retailer.customers.find_by(id: params[:id])
        unless @customer
          render status: 404, json: { message: "Customer not found" }
        end
      end

      def customer_attributes
        params.require(:customer).permit(
          :first_name,
          :last_name,
          :email,
          :phone,
          :notes,
          :address,
          :city,
          :state,
          :zip_code
        )
      end

      def assign_agent(customer, params)
        return unless customer.present? && params[:customer][:agent_id].present?

        agent = current_retailer.retailer_users.find_by_id(params[:customer][:agent_id])
        return unless agent.present?

        assigned_agent = AgentCustomer.find_or_initialize_by(customer_id: customer.id)
        assigned_agent.retailer_user_id = agent.id
        assigned_agent.save
      end
  end
end
