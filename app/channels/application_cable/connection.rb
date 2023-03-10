module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_retailer_user

    def connect
      self.current_retailer_user = find_verified_retailer_user
    end

    private

      def find_verified_retailer_user
        env['warden'].user || reject_unauthorized_connection
      end
  end
end
