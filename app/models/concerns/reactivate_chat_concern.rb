module ReactivateChatConcern
  extend ActiveSupport::Concern

  included do
    after_commit :reactivate, on: :create
  end

  private

    def reactivate
      begin
        return if note
      rescue
      end
      return if direction != 'inbound'

      customer.reactivate_chat!
    end
end
