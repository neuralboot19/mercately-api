namespace :retailers do
  task amount_messages: :environment do
    @start_date = 1.day.ago.beginning_of_day
    @end_date = @start_date.end_of_day
    @calculation_date = @end_date.to_date

    Retailer.find_each do |retailer|
      new_records = []

      # AMOUNT MESSAGES FOR INSTAGRAM
      if retailer.whatsapp_integrated?
        @integration, @status = if retailer.karix_integrated?
          ['karix_whatsapp_messages', 'failed']
        elsif retailer.gupshup_integrated?
          ['gupshup_whatsapp_messages', 'error']
        end

        where_not = if retailer.karix_integrated?
          { status: @status, retailer_user_id: nil }
        else
          { status: @status, retailer_user_id: nil, note: true }
        end

        total_inbound_ws = retailer.send(@integration).range_between(@start_date, @end_date)
          .where(direction: 'inbound').where.not(status: @status).size || 0

        total_outbound_ws = retailer.send(@integration).range_between(@start_date, @end_date)
          .where(direction: 'outbound').where.not(where_not).size || 0

        new_records.push({
          retailer_id: retailer.id,
          calculation_date: @calculation_date,
          ws_inbound: total_inbound_ws,
          ws_outbound: total_outbound_ws,
          total_ws_messages: total_inbound_ws + total_outbound_ws
        })

        # AMOUNT MESSAGES BY AGENT
        ws_messages_by_agent = retailer.send(@integration).group(:retailer_user_id).range_between(@start_date, @end_date)
          .where(direction: 'outbound').where.not(where_not).count
        ws_messages_by_agent.each do |message|
          new_records.push({
            retailer_id: retailer.id,
            calculation_date: @calculation_date,
            ws_inbound: 0,
            ws_outbound: message[1],
            total_ws_messages: message[1],
            retailer_user_id: message[0]
          })
        end
      end

      # AMOUNT MESSAGES FOR MESSENGER
      if retailer.facebook_retailer&.connected?
        total_inbound_msn = retailer.facebook_retailer.facebook_messages
          .range_between(@start_date, @end_date).where(sent_by_retailer: false).size || 0

        total_outbound_msn = retailer.facebook_retailer.facebook_messages
          .range_between(@start_date, @end_date).where(sent_by_retailer: true).where.not(note: true).size || 0

        new_records.push({
          retailer_id: retailer.id,
          calculation_date: @calculation_date,
          msn_inbound: total_inbound_msn,
          msn_outbound: total_outbound_msn,
          total_msn_messages: total_inbound_msn + total_outbound_msn
        })

        # AMOUNT MESSAGES BY AGENT
        msn_messages_by_agent = retailer.facebook_retailer.facebook_messages.group(:retailer_user_id)
        .range_between(@start_date, @end_date).where(sent_by_retailer: true).where.not(note: true).count
        msn_messages_by_agent.each do |message|
          new_records.push({
            retailer_id: retailer.id,
            calculation_date: @calculation_date,
            msn_inbound: 0,
            msn_outbound: message[1],
            total_msn_messages: message[1],
            retailer_user_id: message[0]
          })
        end
      end

      # AMOUNT MESSAGES FOR INSTAGRAM
      if retailer.facebook_retailer&.instagram_integrated?
        total_inbound_ig = retailer.facebook_retailer.instagram_messages
          .range_between(@start_date, @end_date).where(sent_by_retailer: false).size || 0

        total_outbound_ig = retailer.facebook_retailer.instagram_messages
          .range_between(@start_date, @end_date).where(sent_by_retailer: true).where.not(note: true).size || 0

        new_records.push({
          retailer_id: retailer.id,
          calculation_date: @calculation_date,
          ig_inbound: total_inbound_ig,
          ig_outbound: total_outbound_ig,
          total_ig_messages: total_inbound_ig + total_outbound_ig
        })

        # AMOUNT MESSAGES BY AGENT
        ig_messages_by_agent = retailer.facebook_retailer.instagram_messages.group(:retailer_user_id)
        .range_between(@start_date, @end_date).where(sent_by_retailer: true).where.not(note: true).count
        ig_messages_by_agent.each do |message|
          new_records.push({
            retailer_id: retailer.id,
            calculation_date: @calculation_date,
            ig_inbound: 0,
            ig_outbound: message[1],
            total_ig_messages: message[1],
            retailer_user_id: message[0]
          })
        end
      end

      # AMOUNT MESSAGES FOR MERCADO LIBRE
      if retailer.meli_retailer
        total_inbound_ml = Question.unscoped.range_between(@start_date, @end_date)
          .includes(:customer).where(customers: { retailer_id: retailer.id }).where.not(question: [nil, '']).size

        total_outbound_ml = Question.unscoped.range_between(@start_date, @end_date)
          .includes(:customer).where(customers: { retailer_id: retailer.id }).where.not(answer: [nil, '']).size

        new_records.push({
          retailer_id: retailer.id,
          calculation_date: @calculation_date,
          ml_inbound: total_inbound_ml,
          ml_outbound: total_outbound_ml,
          total_ml_messages: total_inbound_ml + total_inbound_ml
        })
      end

      if new_records.any?
        RetailerAmountMessage.create(new_records)
      end
    end
  end
end