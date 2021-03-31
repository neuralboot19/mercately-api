module Retailers::Api::V1
  class CustomersController < Retailers::Api::V1::ApiController
    before_action :check_ownership, only: [:show, :update]
    before_action :set_customer, only: [:show, :update]

    def index
      results = current_retailer.customers.count
      page = params[:page] ? params[:page] : 1
      per_page = 100
      total_pages = (results / per_page) + 1
      customers = current_retailer.customers.page(page.to_i).per(per_page)

      render status: 200, json: {
        results: results,
        total_pages: total_pages,
        customers: serialize_customers(customers),
      }
    end

    def create
      @customer = current_retailer.customers.new(customer_attributes)
      @customer.api_created = true

      if @customer.save
        assign_agent(@customer, params)
        assign_tags(@customer, params)
        render status: 200, json: {
          message: "Customer created successfully",
          customer: Retailers::Api::V1::CustomerSerializer.new(@customer, include: [:tags, :customer_related_data]).as_json
        }
      else
        render status: 302, json: {
          errors: @customer.errors.full_messages
        }
      end
    end

    def show
      render status: 200, json: {
        message: "Customer found successfully",
        customer: Retailers::Api::V1::CustomerSerializer.new(@customer, include: [:tags, :customer_related_data]).as_json
      }
    end

    def update
      assign_tags(@customer, params)
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

      def check_ownership
        customer = Customer.find_by(web_id: params[:id])
        render status: 404, json: { message: "Customer not found" } unless customer && current_retailer.customers.exists?(customer.id)
      end

      def set_customer
        @customer = current_retailer.customers.find_by(web_id: params[:id])
        unless @customer
          render status: 404, json: { message: "Customer not found" }
        end
      end

      def serialize_customers(customers)
        ActiveModelSerializers::SerializableResource.new(
          customers, include: [:tags, :customer_related_data],
          each_serializer: Retailers::Api::V1::CustomerSerializer
        ).as_json
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

      def assign_tags(customer, params)
        return unless customer.present? && params[:customer][:tags].present?

        tags = params[:customer][:tags]
        tags.each do |tag|
          c_tag = current_retailer.tags.find_by(tag: tag['name'])
          if c_tag
            customer.customer_tags.create(tag_id: c_tag.id ) if [true, 'true'].include? tag['value']
            if [false, 'false'].include? tag['value']
              d_tag = customer.customer_tags.find_by(tag_id: c_tag.id)
              d_tag.delete if d_tag
            end
          end
        end
      end
  end
end
