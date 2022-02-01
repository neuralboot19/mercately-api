module Campaigns
  class WhatsappTemplates
    def execute
      campaigns = Campaign.pending.where(send_at: 2.minutes.ago..1.minute.from_now)
      return unless campaigns.exists?

      campaign_ids = campaigns.ids
      campaigns.update_all status: :processing
      Campaign.includes(contact_group: :customers).where(id: campaign_ids).each do |c|
        if c.retailer.ws_balance < c.estimated_cost
          c.update(reason: :insufficient_balance, status: :failed)
          next
        end

        customers = c.contact_group.customers
        customers = if c.retailer.gupshup_integrated?
                      customers.where(whatsapp_opt_in: true).order(ws_bic_cost: :desc)
                    else
                      customers.where.not(phone: [nil, ''])
                    end
        customers.find_in_batches(batch_size: 100) do |batch|
          Campaigns::SendCampaignJob.perform_now(c.id, batch.pluck(:id))
        end

        failed = if c.retailer.gupshup_integrated?
                   c.gupshup_whatsapp_messages.count == c.gupshup_whatsapp_messages.error.count
                 else
                   c.karix_whatsapp_messages.count == c.karix_whatsapp_messages.where(status: 'failed').count
                 end

        if failed
          c.update(reason: :service_down, status: :failed)
          c.failed!
        else
          c.sent!
        end
      rescue => e
        Rails.logger.error e
        SlackError.send_error e
        Raven.capture_exception(e)
      end
    end

  end
end
