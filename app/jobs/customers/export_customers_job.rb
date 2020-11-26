module Customers
  class ExportCustomersJob < ApplicationJob
    queue_as :default

    def perform(retailer_user_id, params)
      @retailer_user = RetailerUser.find(retailer_user_id)
      @retailer = @retailer_user.retailer
      @filtered_by_agent = params[:q]&.[](:agent_id).present?

      active_customers = filtered_customers(@retailer_user.agent?, params)
      active_customers.order(created_at: :desc) if params[:q] && params[:q]&.[](:s).blank?
      q = active_customers.ransack(params[:q])
      customers = q.result

      RetailerMailer.export_customers(@retailer, @retailer_user.email, Customer.to_csv(customers)).deliver_now
    end

    def agent_ids(is_agent, params)
      # An agent is filtering by agent_id, so, will filter
      # only by the current logged in agent
      agent_filtering = is_agent && @filtered_by_agent
      return [@retailer_user.id] if agent_filtering

      # An agent is not filtering by agent_id, so, needed to
      # the default filter to be prepared
      agent_not_filtering = is_agent && !@filtered_by_agent
      return [@retailer_user.id, nil] if agent_not_filtering

      # An admin is filtering by agent_id
      [params[:q]&.[](:agent_id)]
    end

    def filtered_customers(is_agent, params)
      customers = @retailer.customers.active

      if is_agent || @filtered_by_agent
        customers = customers.left_outer_joins(:agent_customer)
          .where(agent_customers: {
            retailer_user_id: agent_ids(is_agent, params)
          })
      end

      customers
    end
  end
end
