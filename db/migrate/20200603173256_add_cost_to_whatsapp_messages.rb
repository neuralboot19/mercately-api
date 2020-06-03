class AddCostToWhatsappMessages < ActiveRecord::Migration[5.2]
  def up
    add_column :karix_whatsapp_messages, :cost, :float
    add_column :gupshup_whatsapp_messages, :cost, :float

    Retailer.where(whats_app_enabled: true).each do |ret|
      integration = ret.karix_integrated? ? 'karix_whatsapp_messages' : 'gupshup_whatsapp_messages'
      failed_status = ret.karix_integrated? ? 'failed' : 0

      # Actualiza el costo de los mensajes de conversacion y notificacion
      # que no fueron fallidos con el costo correspondiente
      # configurado actualmente en el retailer
      %w[conversation notification].each do |message_type|
        ret.send(integration).where(message_type: message_type)
          .where.not(status: failed_status).update_all(cost: ret.send("ws_#{message_type}_cost"))
      end

      # Actualiza el costo de todos los mensajes fallidos a 0
      ret.send(integration).where(status: failed_status).update_all(cost: 0)
    end
  end

  def down
    remove_column :karix_whatsapp_messages, :cost, :float
    remove_column :gupshup_whatsapp_messages, :cost, :float
  end
end
