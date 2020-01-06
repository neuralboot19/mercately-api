module RetailerModelConcern
  extend ActiveSupport::Concern

  # Retorna los mensajes sin leer de facebook messenger
  def facebook_unread_messages
    return [] unless facebook_retailer

    facebook_retailer.facebook_messages.includes(:customer).where(
      date_read: nil,
      sent_by_retailer: false,
      customers: { retailer_id: retailer.id }
    )
  end
end
