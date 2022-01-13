namespace :agents do
  task average_response_time: :environment do
    @start_date = Time.parse(1.day.ago.strftime('%d/%m/%Y'))
    @end_date = @start_date.end_of_day
    @calculation_date = @end_date.to_date
    @unfinished_message_blocks_date = 2.days.ago.to_date

    Retailer.find_each do |retailer|
      @new_records_average_response_times = []
      @new_records_unfinished_message_blocks = []

      # AVERAGE FOR WHATSAPP MESSAGES
      get_average_for_whatsapp_messages(retailer)

      # AVERAGE FOR MESSENGER MESSAGES
      get_average_for_facebook_messages(retailer)

      # AVERAGE FOR INSTAGRAM MESSAGES
      get_average_for_instagram_messages(retailer)

      if @new_records_average_response_times.any?
        RetailerAverageResponseTime.create(@new_records_average_response_times)
      end

      if @new_records_unfinished_message_blocks.any?
        RetailerUnfinishedMessageBlock.create(@new_records_unfinished_message_blocks)
      end

      # Eliminar registro de la tabla retailer_unfinished_message_blocks
      retailer.retailer_unfinished_message_blocks.where(message_date: @unfinished_message_blocks_date, statistics: 0).destroy_all
    end
  end

  def get_average_for_whatsapp_messages(retailer)
    @retailer_user_response_first_time = []
    @retailer_user_response_times = []

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
          "AND statistics = ?", customer[:customer_id], @unfinished_message_blocks_date, 0, 'inbound', 0).first

          if tmp_record.present?
            @retailer_user_response_times.push({
              retailer_user_id: row['retailer_user_id'],
              response_time: Time.parse(row['start_date']) - Time.parse(tmp_record.message_created_date.strftime('%d/%m/%Y %H:%M:%S')),
              occurrences: 1
            })
          end
        else
          if row['direction'] == 'inbound'
            if result_wp.last == row
              # Si es el ultimo registro, y es un inbound se guarda en la tabla auxiliar
              # para el cálculo del siguiente dia
              @new_records_unfinished_message_blocks.push({
                retailer_id: retailer.id,
                customer_id: customer[:customer_id],
                message_created_date: row['start_date'],
                direction: row['direction'],
                platform: 0,
                message_date: @calculation_date,
                statistics: 0
              })
            end

            next
          end

          retailer_user_response_first_time_in = @retailer_user_response_first_time
                                                .find { |retailer_user|
                                                  retailer_user[:retailer_user_id] == row['retailer_user_id'] &&
                                                  retailer_user[:customer_id] == customer[:customer_id]
                                                }

          if retailer_user_response_first_time_in.blank?
            old_conversations = GupshupWhatsappMessage.where("retailer_id = ? AND customer_id = ? AND " \
                                "created_at < ? AND direction = ? AND retailer_user_id = ?" \
                                , retailer.id, customer[:customer_id], @start_date, 'outbound', row['retailer_user_id'])
                                .where.not(note: true).exists?

            if !old_conversations
              @retailer_user_response_first_time.push({
                retailer_user_id: row['retailer_user_id'],
                customer_id: customer[:customer_id],
                response_first_time: Time.parse(row['start_date']) - Time.parse(result_wp[index - 1]['start_date'])
              })
            end
          end

          # Calcular el tiempo de respuesta para el bloque de mensajes
          retailer_user_in = @retailer_user_response_times.find { |retailer_user|
            retailer_user[:retailer_user_id] == row['retailer_user_id']
          }
          response_time = Time.parse(row['start_date']) - Time.parse(result_wp[index - 1]['start_date'])

          if retailer_user_in.present?
            retailer_user_in[:response_time] += response_time
            retailer_user_in[:occurrences] += 1
          else
            @retailer_user_response_times.push({
              retailer_user_id: row['retailer_user_id'],
              response_time: response_time,
              occurrences: 1
            })
          end
        end
      end
    end

    total_retailer_user = @retailer_user_response_times.count

    return unless total_retailer_user > 0

    total_first_time_average = 0
    total_conversation_time_average = 0

    @retailer_user_response_times.each do |retailer_user|
      first_time_average = 0
      occurrences = 0

      @retailer_user_response_first_time.each do |retailer_user_first_time|
        next unless retailer_user[:retailer_user_id] == retailer_user_first_time[:retailer_user_id]

        first_time_average += retailer_user_first_time[:response_first_time]
        occurrences += 1
      end

      first_time_average = first_time_average / occurrences if occurrences > 0
      conversation_time_average = retailer_user[:response_time] / retailer_user[:occurrences]

      total_first_time_average += first_time_average
      total_conversation_time_average += conversation_time_average

      @new_records_average_response_times.push({
        first_time_average: first_time_average.round(2),
        conversation_time_average: conversation_time_average.round(2),
        retailer_id: retailer.id,
        retailer_user_id: retailer_user[:retailer_user_id],
        calculation_date: @calculation_date,
        platform: 0
      })
    end

    @new_records_average_response_times.push({
      first_time_average: (total_first_time_average / total_retailer_user).round(2),
      conversation_time_average: (total_conversation_time_average / total_retailer_user).round(2),
      retailer_id: retailer.id,
      calculation_date: @calculation_date,
      platform: 0
    })
  end

  def get_average_for_facebook_messages(retailer)
    @retailer_user_response_first_time = []
    @retailer_user_response_times = []

    return unless retailer.facebook_retailer&.connected?

    # Obtener los ids de los customers que hayan escrito en el rango de fecha, esto es agrupado
    retailer.facebook_retailer.facebook_messages.select(:customer_id).distinct
    .where("created_at >= ? AND created_at <= ? AND " \
    "(sent_by_retailer = ? OR (sent_by_retailer = ? AND retailer_user_id IS NOT NULL))", @start_date, @end_date, false, true)
    .where.not(note: true)
    .each do |customer|
      # Agrupar por bloques de mensajes tanto inbound como outbound por customer
      # y por el primerer retailer_user que responde
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
          WHERE tbl_fm.customer_id = :customer_id
            AND note = :note
            AND (tbl_fm.sent_by_retailer = false OR (tbl_fm.sent_by_retailer = true AND tbl_fm.retailer_user_id IS NOT NULL))
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

      result_msn.each_with_index  do |row, index|
        if index == 0 && row['sent_by_retailer'] == true
          # Si el primer bloque es un outbound se valida con la tabla donde se guardo el bloque
          # de mensajes inbound que no tuvo un outbound
          tmp_record = retailer.retailer_unfinished_message_blocks
                      .where("customer_id = ? AND message_date = ? AND platform = ? AND statistics = ? " \
                      "AND sent_by_retailer = ?", customer[:customer_id], @unfinished_message_blocks_date, 1, 0, false).first

          if tmp_record.present?
            @retailer_user_response_times.push({
              retailer_user_id: row['retailer_user_id'],
              response_time: Time.parse(row['start_date']) - Time.parse(tmp_record.message_created_date.strftime('%d/%m/%Y %H:%M:%S')),
              occurrences: 1
            })
          end
        else
          if row['sent_by_retailer'] == false
            if result_msn.last == row
              # Si es el ultimo registro, y es un inbound se guarda en la tabla auxiliar
              # para el cálculo del siguiente dia
              @new_records_unfinished_message_blocks.push({
                retailer_id: retailer.id,
                customer_id: customer[:customer_id],
                message_created_date: row['start_date'],
                sent_by_retailer: row['sent_by_retailer'],
                platform: 1,
                message_date: @calculation_date,
                statistics: 0
              })
            end

            next
          end

          retailer_user_response_first_time_in = @retailer_user_response_first_time
                                                .find { |retailer_user|
                                                  retailer_user[:retailer_user_id] == row['retailer_user_id'] &&
                                                  retailer_user[:customer_id] == customer[:customer_id]
                                                }

          if retailer_user_response_first_time_in.blank?
            old_conversations = retailer.facebook_retailer.facebook_messages
                              .where("created_at < ? AND customer_id = ? AND sent_by_retailer = ? AND " \
                              "retailer_user_id = ? ", @start_date, customer[:customer_id], true, row['retailer_user_id'])
                              .where.not(note: true).exists?

            if !old_conversations
              @retailer_user_response_first_time.push({
                retailer_user_id: row['retailer_user_id'],
                customer_id: customer[:customer_id],
                response_first_time: Time.parse(row['start_date']) - Time.parse(result_msn[index - 1]['start_date'])
              })
            end
          end

          # Calcular el tiempo de respuesta para el bloque de mensajes
          retailer_user_in = @retailer_user_response_times.find { |retailer_user|
            retailer_user[:retailer_user_id] == row['retailer_user_id']
          }
          response_time = Time.parse(row['start_date']) - Time.parse(result_msn[index - 1]['start_date'])

          if retailer_user_in.present?
            retailer_user_in[:response_time] += response_time
            retailer_user_in[:occurrences] += 1
          else
            @retailer_user_response_times.push({
              retailer_user_id: row['retailer_user_id'],
              response_time: response_time,
              occurrences: 1
            })
          end
        end
      end
    end

    total_retailer_user = @retailer_user_response_times.count

    return unless total_retailer_user > 0

    total_first_time_average = 0
    total_conversation_time_average = 0

    @retailer_user_response_times.each do |retailer_user|
      first_time_average = 0
      occurrences = 0

      @retailer_user_response_first_time.each do |retailer_user_first_time|
        next unless retailer_user[:retailer_user_id] == retailer_user_first_time[:retailer_user_id]

        first_time_average += retailer_user_first_time[:response_first_time]
        occurrences += 1
      end

      first_time_average = first_time_average / occurrences if occurrences > 0
      conversation_time_average = retailer_user[:response_time] / retailer_user[:occurrences]

      total_first_time_average += first_time_average
      total_conversation_time_average += conversation_time_average

      @new_records_average_response_times.push({
        first_time_average: first_time_average.round(2),
        conversation_time_average: conversation_time_average.round(2),
        retailer_id: retailer.id,
        retailer_user_id: retailer_user[:retailer_user_id],
        calculation_date: @calculation_date,
        platform: 1
      })
    end

    @new_records_average_response_times.push({
      first_time_average: (total_first_time_average / total_retailer_user).round(2),
      conversation_time_average: (total_conversation_time_average / total_retailer_user).round(2),
      retailer_id: retailer.id,
      calculation_date: @calculation_date,
      platform: 1
    })
  end

  def get_average_for_instagram_messages(retailer)
    @retailer_user_response_first_time = []
    @retailer_user_response_times = []

    return unless retailer.facebook_retailer&.instagram_integrated?

    # Obtener los ids de los customers que hayan escrito en el rango de fecha, esto es agrupado
    retailer.facebook_retailer.instagram_messages.select(:customer_id).distinct
    .where("created_at >= ? AND created_at <= ? AND " \
    "(sent_by_retailer = ? OR (sent_by_retailer = ? AND retailer_user_id IS NOT NULL))", @start_date, @end_date, false, true)
    .where.not(note: true)
    .each do |customer|
      # Agrupar por bloques de mensajes tanto inbound como outbound por customer
      # y por el primerer retailer_user que responde
      sql_message_grouped_ig = <<-SQL
        SELECT
          MIN(created_at) start_date,
          MAX(created_at) end_date, sent_by_retailer,
          count(sent_by_retailer) messages,
          (ARRAY_AGG(retailer_user_id ORDER BY created_at ASC))[1] retailer_user_id
        FROM (
          SELECT
          tbl_ig.sent_by_retailer, tbl_ig.created_at, tbl_ig.retailer_user_id,
            ROW_NUMBER() OVER(ORDER BY tbl_ig.created_at) rn1,
            ROW_NUMBER() OVER(partition by tbl_ig.sent_by_retailer ORDER BY tbl_ig.created_at) rn2
          FROM instagram_messages tbl_ig
          WHERE tbl_ig.customer_id = :customer_id
            AND note = :note
            AND (tbl_ig.sent_by_retailer = false OR (tbl_ig.sent_by_retailer = true AND tbl_ig.retailer_user_id IS NOT NULL))
            AND tbl_ig.created_at >= :start_date AND tbl_ig.created_at <= :end_date
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

      result_ig.each_with_index  do |row, index|
        if index == 0 && row['sent_by_retailer'] == true
          # Si el primer bloque es un outbound se valida con la tabla donde se guardo el bloque
          # de mensajes inbound que no tuvo un outbound
          tmp_record = retailer.retailer_unfinished_message_blocks.where(
                      "customer_id = ? AND message_date = ? AND platform = ? AND sent_by_retailer = ? AND statistics = ?",
                      customer[:customer_id], @unfinished_message_blocks_date, 2, false, 0).first

          if tmp_record.present?
            @retailer_user_response_times.push({
              retailer_user_id: row['retailer_user_id'],
              response_time: Time.parse(row['start_date']) - Time.parse(tmp_record.message_created_date.strftime('%d/%m/%Y %H:%M:%S')),
              occurrences: 1
            })
          end
        else
          if row['sent_by_retailer'] == false
            if result_ig.last == row
              # Si es el ultimo registro, y es un inbound se guarda en la tabla auxiliar
              # para el cálculo del siguiente dia
              @new_records_unfinished_message_blocks.push({
                retailer_id: retailer.id,
                customer_id: customer[:customer_id],
                message_created_date: row['start_date'],
                sent_by_retailer: row['sent_by_retailer'],
                platform: 2,
                message_date: @calculation_date,
                statistics: 0
              })
            end

            next
          end

          retailer_user_response_first_time_in = @retailer_user_response_first_time
                                                .find { |retailer_user|
                                                  retailer_user[:retailer_user_id] == row['retailer_user_id'] &&
                                                  retailer_user[:customer_id] == customer[:customer_id]
                                                }

          if retailer_user_response_first_time_in.blank?
            old_conversations = retailer.facebook_retailer.instagram_messages
                              .where("created_at < ? AND customer_id = ? AND sent_by_retailer = ? AND " \
                              "retailer_user_id = ? ", @start_date, customer[:customer_id], true, row['retailer_user_id'])
                              .where.not(note: true).exists?

            if !old_conversations
              @retailer_user_response_first_time.push({
                retailer_user_id: row['retailer_user_id'],
                customer_id: customer[:customer_id],
                response_first_time: Time.parse(row['start_date']) - Time.parse(result_ig[index - 1]['start_date'])
              })
            end
          end

          # Calcular el tiempo de respuesta para el bloque de mensajes
          retailer_user_in = @retailer_user_response_times.find {
            |retailer_user| retailer_user[:retailer_user_id] == row['retailer_user_id']
          }
          response_time = Time.parse(row['start_date']) - Time.parse(result_ig[index - 1]['start_date'])

          if retailer_user_in.present?
            retailer_user_in[:response_time] += response_time
            retailer_user_in[:occurrences] += 1
          else
            @retailer_user_response_times.push({
              retailer_user_id: row['retailer_user_id'],
              response_time: response_time,
              occurrences: 1
            })
          end
        end
      end
    end

    total_retailer_user = @retailer_user_response_times.count

    return unless total_retailer_user > 0

    total_first_time_average = 0
    total_conversation_time_average = 0

    @retailer_user_response_times.each do |retailer_user|
      first_time_average = 0
      occurrences = 0

      @retailer_user_response_first_time.each do |retailer_user_first_time|
        next unless retailer_user[:retailer_user_id] == retailer_user_first_time[:retailer_user_id]

        first_time_average += retailer_user_first_time[:response_first_time]
        occurrences += 1
      end

      first_time_average = first_time_average / occurrences if occurrences > 0
      conversation_time_average = retailer_user[:response_time] / retailer_user[:occurrences]

      total_first_time_average += first_time_average
      total_conversation_time_average += conversation_time_average

      @new_records_average_response_times.push({
        first_time_average: first_time_average.round(2),
        conversation_time_average: conversation_time_average.round(2),
        retailer_id: retailer.id,
        retailer_user_id: retailer_user[:retailer_user_id],
        calculation_date: @calculation_date,
        platform: 2
      })
    end

    @new_records_average_response_times.push({
      first_time_average: (total_first_time_average / total_retailer_user).round(2),
      conversation_time_average: (total_conversation_time_average / total_retailer_user).round(2),
      retailer_id: retailer.id,
      calculation_date: @calculation_date,
      platform: 2
    })
  end
end
