module ApiDoc
  module V1
    module Product
      extend Dox::DSL::Syntax

      document :api do
        resource 'Products' do
          endpoint '/retailers/api/v1/products/:id'
          group 'Products'
          desc 'Documentation of product resources'
        end
      end

      # define data for specific action
      document :index do
        action 'Get all products'
      end

      document :show do
        action 'Get a product'
      end

      document :create do
        action 'Create a product'
      end

      document :update do
        action 'Update a product'
      end
    end
  end
end
