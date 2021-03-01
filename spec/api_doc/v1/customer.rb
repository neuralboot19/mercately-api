module ApiDoc
  module V1
    module Customer
      extend Dox::DSL::Syntax

      document :api do
        resource 'Customers' do
          endpoint '/retailers/api/v1/customers/:id'
          group 'Customers'
          desc 'Documentation of customer resources'
        end
      end

      # define data for specific action
      document :update do
        action 'Update a customer'
      end
    end
  end
end
