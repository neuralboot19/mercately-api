namespace :charges do
  task refund_conversations: :environment do
    RetailerWhatsappConversation.all.each do |rwc|
      retailer = rwc.retailer

      if (rwc.user_initiated_total + rwc.business_initiated_total) <= 1000
        refund = rwc.user_initiated_cost + rwc.business_initiated_cost
        retailer.update_column(:ws_balance, retailer.ws_balance + refund)

        rwc.update_columns(
          free_uic_total: rwc.free_uic_total + rwc.user_initiated_total,
          free_bic_total: rwc.free_bic_total + rwc.business_initiated_total
        )

        rwc.update_columns(
          user_initiated_total: 0,
          business_initiated_total: 0,
          user_initiated_cost: 0.0,
          business_initiated_cost: 0.0
        )

        rwc.country_conversations.update_all(
          total_cost_uic: 0.0,
          total_uic: 0,
          total_cost_bic: 0.0,
          total_bic: 0
        )
      else
        puts "Retailer con más de 1000 conversaciones #{rwc.retailer.id} #{rwc.retailer.name}"
      end
    end
  end
end
