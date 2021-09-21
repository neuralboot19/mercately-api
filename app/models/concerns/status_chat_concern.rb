module StatusChatConcern
  extend ActiveSupport::Concern

  included do
    after_commit :set_status, on: :create
  end

  private

    def set_status
      begin
        return if note
      rescue
      end
      return unless retailer_user.present?

      customer.set_in_process(retailer_user, true)
    end
end
