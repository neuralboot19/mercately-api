module CustomerActiveWhatsappConcern
  extend ActiveSupport::Concern

  included do
    after_commit :set_active_whatsapp, on: :create
  end

  private

    def set_active_whatsapp
      if retailer.karix_integrated?
        customer.update_columns(ws_active: true, last_chat_interaction: created_time)
      elsif retailer.gupshup_integrated? && !note
        customer.update_columns(ws_active: true, last_chat_interaction: created_at)
      end
    end
end
