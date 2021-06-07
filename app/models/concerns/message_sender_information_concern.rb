module MessageSenderInformationConcern
  extend ActiveSupport::Concern

  included do
    before_create :set_sender_information
  end

  private

    def set_sender_information
      return unless retailer_user.present?

      self.sender_first_name = retailer_user.first_name
      self.sender_last_name = retailer_user.last_name
      self.sender_email = retailer_user.email
    end
end
