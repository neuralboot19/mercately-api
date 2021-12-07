namespace :retailers do
  task new_and_recurring_conversations: :environment do
    @start_date = Time.parse(1.day.ago.strftime('%d/%m/%Y'))
    @end_date = @start_date.end_of_day
    @calculation_date = @end_date.to_date
    @unfinished_message_blocks_date = 2.day.ago.to_date

    Retailer.find_each do |retailer|
      @new_retailer_user_customer_conversations = []
      @new_records_unfinished_message_blocks = []

      # STATISTICS FOR WHATSAPP MESSAGES
      conversation_statistics_for_wp(retailer)

      # STATISTICS FOR MESSENGER MESSAGES
      conversation_statistics_for_msn(retailer)

      # STATISTICS FOR INSTAGRAM MESSAGES
      conversation_statistics_for_ig(retailer)

      if @new_retailer_user_customer_conversations.any?
        RetailerConversation.create(@new_retailer_user_customer_conversations)
      end

      if @new_records_unfinished_message_blocks.any?
        RetailerUnfinishedMessageBlock.create(@new_records_unfinished_message_blocks)
      end

      # Eliminar registro de la tabla retailer_unfinished_message_blocks
      retailer.retailer_unfinished_message_blocks.where(message_date: @unfinished_message_blocks_date, statistics: 1).destroy_all
    end
  end

  def conversation_statistics_for_wp(retailer)
    @retailer_user_customer_conversations = []
    @retailer_user_conversations = []

    return unless retailer.gupshup_integrated?

    # Obtener los ids de los customers que hayan escrito en el rango de fecha, esto es agrupado
    retailer.gupshup_whatsapp_messages
    .select(:customer_id).distinct
    .where("gupshup_whatsapp_messages.created_at >= ? AND gupshup_whatsapp_messages.created_at <= ? AND status != ? AND " \
    "(direction = ? OR (direction = ? AND retailer_user_id IS NOT NULL))", @start_date, @end_date, 0, 'inbound', 'outbound')
    .where.not(note: true).each do |customer|
      # Agrupar por bloques de mensajes tanto inbound como outbound por customer
      # y por el primer retailer_user que responde
      sql_message_grouped_wp = <<-SQL
        SELECT
          MIN(created_at) start_date,
          MAX(created_at) end_date, direction,
          count(direction) messages,
          (ARRAY_AGG(retailer_user_id ORDER BY created_at ASC))[1] retailer_user_id
        FROM (
          SELECT
            tbl_gwm.direction, tbl_gwm.created_at, tbl_gwm.retailer_user_id,
            ROW_NUMBER() OVER(ORDER BY tbl_gwm.created_at) rn1,
            ROW_NUMBER() OVER(partition by tbl_gwm.direction ORDER BY tbl_gwm.created_at) rn2
          FROM gupshup_whatsapp_messages tbl_gwm
          WHERE customer_id = :customer_id
            AND note = :note
            AND (tbl_gwm.direction = 'inbound' OR (tbl_gwm.direction = 'outbound' AND retailer_user_id IS NOT NULL))
            AND tbl_gwm.created_at >= :start_date AND tbl_gwm.created_at <= :end_date
            AND tbl_gwm.status != 0
        ) tbl_result_1
        GROUP BY direction, rn1 - rn2
        ORDER BY MIN(created_at)
      SQL

      result_wp = ActiveRecord::Base.connection.exec_query(
        ApplicationRecord.sanitize_sql([
          sql_message_grouped_wp, {
            customer_id: customer[:customer_id],
            note: false,
            start_date: @start_date,
            end_date: @end_date
          }
        ])
      )

      result_wp.each_with_index do |row, index|
        if index == 0 && row['direction'] == 'outbound'
          # Si el primer bloque es un outbound se valida con la tabla donde se guardo el bloque
          # de mensajes inbound que no tuvo un outbound
          tmp_record = retailer.retailer_unfinished_message_blocks
                              .where("customer_id = ? AND message_date = ? AND platform = ? AND direction = ? " \
                              "AND statistics = ?", customer[:customer_id], @unfinished_message_blocks_date, 0, 'inbound', 1).exists?

          if tmp_record
            @retailer_user_customer_conversations.push({
              retailer_user_id: row['retailer_user_id'],
              customer_id: customer[:customer_id]
            })

            check_old_conversations('ws', retailer, customer[:customer_id], row['retailer_user_id'])
          end
        else
          if row['direction'] == 'inbound'
            if result_wp.last == row
              # Si es el ultimo registro, y es un inbound se guarda en la tabla auxiliar
              # para el calculo del siguiente dia
              @new_records_unfinished_message_blocks.push({
                retailer_id: retailer.id,
                customer_id: customer[:customer_id],
                message_created_date: row['start_date'],
                direction: row['direction'],
                platform: 0,
                message_date: @calculation_date,
                statistics: 1
              })
            end

            next
          end

          retailer_user_customer_in = @retailer_user_customer_conversations
                                      .find { |retailer_user|
                                        retailer_user[:retailer_user_id] == row['retailer_user_id'] &&
                                        retailer_user[:customer_id] == customer[:customer_id]
                                      }
          next unless retailer_user_customer_in.blank?

          @retailer_user_customer_conversations.push({
            retailer_user_id: row['retailer_user_id'],
            customer_id: customer[:customer_id]
          })

          check_old_conversations('ws', retailer, customer[:customer_id], row['retailer_user_id'])
        end
      end
    end

    return unless @retailer_user_conversations.count > 0

    total_new_conversations = 0
    total_recurring_conversations = 0

    @retailer_user_conversations.each do |retailer_user|
      total_new_conversations += retailer_user[:new_conversations]
      total_recurring_conversations += retailer_user[:recurring_conversations]

      @new_retailer_user_customer_conversations.push({
        retailer_id: retailer.id,
        retailer_user_id: retailer_user[:retailer_user_id],
        calculation_date: @calculation_date,
        platform: 0,
        new_conversations: retailer_user[:new_conversations],
        recurring_conversations: retailer_user[:recurring_conversations]
      })
    end

    @new_retailer_user_customer_conversations.push({
      retailer_id: retailer.id,
      calculation_date: @calculation_date,
      platform: 0,
      new_conversations: total_new_conversations,
      recurring_conversations: total_recurring_conversations
    })
  end

  def conversation_statistics_for_msn(retailer)
    @retailer_user_customer_conversations = []
    @retailer_user_conversations = []

    return unless retailer.facebook_retailer&.connected?

    # Obtener los ids de los customers que hayan escrito en el rango de fecha, esto es agrupado
    retailer.facebook_retailer.facebook_messages.select(:customer_id).distinct
    .where("created_at >= ? AND created_at <= ? AND " \
    "(sent_by_retailer = ? OR (sent_by_retailer = ? AND retailer_user_id IS NOT NULL))", @start_date, @end_date, false, true)
    .where.not(note: true)
    .each do |customer|
      # Agrupar por bloques de mensajes tanto inbound como outbound por customer
      # y por el primer retailer_user que responde
      sql_message_grouped_msn = <<-SQL
        SELECT
          MIN(created_at) start_date,
          MAX(created_at) end_date, sent_by_retailer,
          count(sent_by_retailer) messages,
          (ARRAY_AGG(retailer_user_id ORDER BY created_at ASC))[1] retailer_user_id
        FROM (
          SELECT
            tbl_fm.sent_by_retailer, tbl_fm.created_at, tbl_fm.retailer_user_id,
            ROW_NUMBER() OVER(ORDER BY tbl_fm.created_at) rn1,
            ROW_NUMBER() OVER(partition by tbl_fm.sent_by_retailer ORDER BY tbl_fm.created_at) rn2
          FROM facebook_messages tbl_fm
          WHERE customer_id = :customer_id
            AND note = :note
            AND (tbl_fm.sent_by_retailer = false OR (tbl_fm.sent_by_retailer = true AND retailer_user_id IS NOT NULL))
            AND tbl_fm.created_at >= :start_date AND tbl_fm.created_at <= :end_date
        ) tbl_result_1
        GROUP BY sent_by_retailer, rn1 - rn2
        ORDER BY MIN(created_at)
      SQL

      result_msn = ActiveRecord::Base.connection.exec_query(
        ApplicationRecord.sanitize_sql([
          sql_message_grouped_msn, {
            customer_id: customer[:customer_id],
            note: false,
            start_date: @start_date,
            end_date: @end_date
          }
        ])
      )

      result_msn.each_with_index do |row, index|
        if index == 0 && row['sent_by_retailer'] == true
          # Si el primer bloque es un outbound se valida con la tabla donde se guardo el bloque
          # de mensajes inbound que no tuvo un outbound
          tmp_record = retailer.retailer_unfinished_message_blocks
                              .where("customer_id = ? AND message_date = ? AND platform = ? AND statistics = ? " \
                              "AND sent_by_retailer = ?", customer[:customer_id], @unfinished_message_blocks_date, 1, 1, false).exists?

          if tmp_record
            @retailer_user_customer_conversations.push({
              retailer_user_id: row['retailer_user_id'],
              customer_id: customer[:customer_id]
            })

            check_old_conversations('msn', retailer, customer[:customer_id], row['retailer_user_id'])
          end
        else
          if row['sent_by_retailer'] == false
            if result_msn.last == row
              # Si es el ultimo registro, y es un inbound se guarda en la tabla auxiliar
              # para el calculo del siguiente dia
              @new_records_unfinished_message_blocks.push({
                retailer_id: retailer.id,
                customer_id: customer[:customer_id],
                message_created_date: row['start_date'],
                sent_by_retailer: row['sent_by_retailer'],
                platform: 1,
                message_date: @calculation_date,
                statistics: 1
              })
            end

            next
          end

          retailer_user_customer_in = @retailer_user_customer_conversations
                                      .find { |retailer_user|
                                        retailer_user[:retailer_user_id] == row['retailer_user_id'] &&
                                        retailer_user[:customer_id] == customer[:customer_id]
                                      }
          next unless retailer_user_customer_in.blank?

          @retailer_user_customer_conversations.push({
            retailer_user_id: row['retailer_user_id'],
            customer_id: customer[:customer_id]
          })

          check_old_conversations('msn', retailer, customer[:customer_id], row['retailer_user_id'])
        end
      end
    end

    return unless @retailer_user_conversations.count > 0

    total_new_conversations = 0
    total_recurring_conversations = 0

    @retailer_user_conversations.each do |retailer_user|
      total_new_conversations += retailer_user[:new_conversations]
      total_recurring_conversations += retailer_user[:recurring_conversations]

      @new_retailer_user_customer_conversations.push({
        retailer_id: retailer.id,
        retailer_user_id: retailer_user[:retailer_user_id],
        calculation_date: @calculation_date,
        platform: 1,
        new_conversations: retailer_user[:new_conversations],
        recurring_conversations: retailer_user[:recurring_conversations]
      })
    end

    @new_retailer_user_customer_conversations.push({
      retailer_id: retailer.id,
      calculation_date: @calculation_date,
      platform: 1,
      new_conversations: total_new_conversations,
      recurring_conversations: total_recurring_conversations
    })
  end

  def conversation_statistics_for_ig(retailer)
    @retailer_user_customer_conversations = []
    @retailer_user_conversations = []

    return unless retailer.facebook_retailer&.instagram_integrated?

    # Obtener los ids de los customers que hayan escrito en el rango de fecha, esto es agrupado
    retailer.facebook_retailer.instagram_messages.select(:customer_id).distinct
    .where("created_at >= ? AND created_at <= ? AND " \
    "(sent_by_retailer = ? OR (sent_by_retailer = ? AND retailer_user_id IS NOT NULL))", @start_date, @end_date, false, true)
    .where.not(note: true)
    .each do |customer|
      # Agrupar por bloques de mensajes tanto inbound como outbound por customer
      # y por el primer retailer_user que responde
      sql_message_grouped_ig = <<-SQL
        SELECT
          MIN(created_at) start_date,
          MAX(created_at) end_date, sent_by_retailer,
          count(sent_by_retailer) messages,
          (ARRAY_AGG(retailer_user_id ORDER BY created_at ASC))[1] retailer_user_id
        FROM (
          SELECT
            tbl_igm.sent_by_retailer, tbl_igm.created_at, tbl_igm.retailer_user_id,
            ROW_NUMBER() OVER(ORDER BY tbl_igm.created_at) rn1,
            ROW_NUMBER() OVER(partition by tbl_igm.sent_by_retailer ORDER BY tbl_igm.created_at) rn2
          FROM instagram_messages tbl_igm
          WHERE customer_id = :customer_id
            AND note = :note
            AND (tbl_igm.sent_by_retailer = false OR (tbl_igm.sent_by_retailer = true AND retailer_user_id IS NOT NULL))
            AND tbl_igm.created_at >= :start_date AND tbl_igm.created_at <= :end_date
        ) tbl_result_1
        GROUP BY sent_by_retailer, rn1 - rn2
        ORDER BY MIN(created_at)
      SQL

      result_ig = ActiveRecord::Base.connection.exec_query(
        ApplicationRecord.sanitize_sql([
          sql_message_grouped_ig, {
            customer_id: customer[:customer_id],
            note: false,
            start_date: @start_date,
            end_date: @end_date
          }
        ])
      )

      result_ig.each_with_index do |row, index|
        if index == 0 && row['sent_by_retailer'] == true
          # Si el primer bloque es un outbound se valida con la tabla donde se guardo el bloque
          # de mensajes inbound que no tuvo un outbound
          tmp_record = retailer.retailer_unfinished_message_blocks.where(
                              "customer_id = ? AND message_date = ? AND platform = ? AND sent_by_retailer = ? AND statistics = ?",
                              customer[:customer_id], @unfinished_message_blocks_date, 2, false, 1).exists?

          if tmp_record
            @retailer_user_customer_conversations.push({
              retailer_user_id: row['retailer_user_id'],
              customer_id: customer[:customer_id]
            })

            check_old_conversations('ig', retailer, customer[:customer_id], row['retailer_user_id'])
          end
        else
          if row['sent_by_retailer'] == false
            if result_ig.last == row
              # Si es el ultimo registro, y es un inbound se guarda en la tabla auxiliar
              # para el calculo del siguiente dia
              @new_records_unfinished_message_blocks.push({
                retailer_id: retailer.id,
                customer_id: customer[:customer_id],
                message_created_date: row['start_date'],
                sent_by_retailer: row['sent_by_retailer'],
                platform: 2,
                message_date: @calculation_date,
                statistics: 1
              })
            end

            next
          end

          retailer_user_customer_in = @retailer_user_customer_conversations
                                      .find { |retailer_user|
                                        retailer_user[:retailer_user_id] == row['retailer_user_id'] &&
                                        retailer_user[:customer_id] == customer[:customer_id]
                                      }
          next unless retailer_user_customer_in.blank?

          @retailer_user_customer_conversations.push({
            retailer_user_id: row['retailer_user_id'],
            customer_id: customer[:customer_id]
          })

          check_old_conversations('ig', retailer, customer[:customer_id], row['retailer_user_id'])
        end
      end
    end

    return unless @retailer_user_conversations.count > 0

    total_new_conversations = 0
    total_recurring_conversations = 0

    @retailer_user_conversations.each do |retailer_user|
      total_new_conversations += retailer_user[:new_conversations]
      total_recurring_conversations += retailer_user[:recurring_conversations]

      @new_retailer_user_customer_conversations.push({
        retailer_id: retailer.id,
        retailer_user_id: retailer_user[:retailer_user_id],
        calculation_date: @calculation_date,
        platform: 2,
        new_conversations: retailer_user[:new_conversations],
        recurring_conversations: retailer_user[:recurring_conversations]
      })
    end

    @new_retailer_user_customer_conversations.push({
      retailer_id: retailer.id,
      calculation_date: @calculation_date,
      platform: 2,
      new_conversations: total_new_conversations,
      recurring_conversations: total_recurring_conversations
    })
  end

  def check_old_conversations(platform, retailer, customer_id, retailer_user_id)
    old_conversations = case platform
                        when 'ws'
                          GupshupWhatsappMessage
                          .where("retailer_id = ? AND customer_id = ? AND " \
                          "created_at < ? AND direction = ? AND retailer_user_id = ?",
                          retailer.id, customer_id, @start_date, 'outbound', retailer_user_id)
                          .where.not(note: true).exists?
                        when 'msn'
                          retailer
                          .facebook_retailer.facebook_messages
                          .where("created_at < ? AND customer_id = ? AND sent_by_retailer = ? AND " \
                          "retailer_user_id = ? ", @start_date, customer_id, true, retailer_user_id)
                          .where.not(note: true).exists?
                        when 'ig'
                          retailer
                          .facebook_retailer.instagram_messages
                          .where("created_at < ? AND customer_id = ? AND sent_by_retailer = ? AND " \
                          "retailer_user_id = ? ", @start_date, customer_id, true, retailer_user_id)
                          .where.not(note: true).exists?
                        end

    if old_conversations
      new_conversations = 0
      recurring_conversations = 1
    else
      new_conversations = 1
      recurring_conversations = 0
    end

    retailer_user_in = @retailer_user_conversations
                      .find { |retailer_user|
                        retailer_user[:retailer_user_id] == retailer_user_id
                      }

    if retailer_user_in.present?
      retailer_user_in[:new_conversations] += new_conversations
      retailer_user_in[:recurring_conversations] += recurring_conversations
    else
      @retailer_user_conversations.push({
        retailer_user_id: retailer_user_id,
        new_conversations: new_conversations,
        recurring_conversations: recurring_conversations
      })
    end
  end
end