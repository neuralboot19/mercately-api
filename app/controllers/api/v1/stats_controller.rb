class Api::V1::StatsController < Api::ApiController
  include CurrentRetailer

  # GET /api/v1/stats/messages_by_platform
  def messages_by_platform
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      amount_messages = current_retailer
                        .retailer_amount_messages
                        .range_between(start_date, end_date)
                        .where('retailer_user_id IS NULL')
                        .order(:calculation_date)

      ws_data = []
      total_inbound_ws = 0
      total_outbound_ws = 0
      msn_data = []
      total_inbound_msn = 0
      total_outbound_msn = 0
      ig_data = []
      total_inbound_ig = 0
      total_outbound_ig = 0
      ml_data = []
      total_inbound_ml = 0
      total_outbound_ml = 0

      amount_messages.each do |row|
        ws_data_in = ws_data.find { |data| data[:date] == row[:calculation_date] }

        if ws_data_in.blank?
          ws_data.push({date: row[:calculation_date], amount: row[:total_ws_messages]})
        else
          ws_data_in[:amount] += row[:total_ws_messages]
        end

        total_inbound_ws += row[:ws_inbound]
        total_outbound_ws += row[:ws_outbound]

        msn_data_in = msn_data.find { |data| data[:date] == row[:calculation_date] }

        if msn_data_in.blank?
          msn_data.push({date: row[:calculation_date], amount: row[:total_msn_messages]})
        else
          msn_data_in[:amount] += row[:total_msn_messages]
        end

        total_inbound_msn += row[:msn_inbound]
        total_outbound_msn += row[:msn_outbound]

        ig_data_in = ig_data.find { |data| data[:date] == row[:calculation_date] }

        if ig_data_in.blank?
          ig_data.push({date: row[:calculation_date], amount: row[:total_ig_messages]})
        else
          ig_data_in[:amount] += row[:total_ig_messages]
        end

        total_inbound_ig += row[:ig_inbound]
        total_outbound_ig += row[:ig_outbound]

        ml_data_in = ml_data.find { |data| data[:date] == row[:calculation_date] }

        if ml_data_in.blank?
          ml_data.push({date: row[:calculation_date], amount: row[:total_ml_messages]})
        else
          ml_data_in[:amount] += row[:total_ml_messages]
        end

        total_inbound_ml += row[:ml_inbound]
        total_outbound_ml += row[:ml_outbound]
      end

      response = {
        "ws": {
          "total_inbound": total_inbound_ws,
          "total_outbound": total_outbound_ws,
          "total_messages": total_inbound_ws + total_outbound_ws,
          "data": ws_data
        },
        "msn": {
          "total_inbound": total_inbound_msn,
          "total_outbound": total_outbound_msn,
          "total_messages": total_inbound_msn + total_outbound_msn,
          "data": msn_data
        },
        "ig": {
          "total_inbound": total_inbound_ig,
          "total_outbound": total_outbound_ig,
          "total_messages": total_inbound_ig + total_outbound_ig,
          "data": ig_data
        },
        "ml": {
          "total_inbound": total_inbound_ml,
          "total_outbound": total_outbound_ml,
          "total_messages": total_inbound_ml + total_outbound_ml,
          "data": ml_data
        }
      }

      render status: 200, json: { messages_by_platform: response }
    else
      render json: { error: "not records" }, status: :not_found
    end
  end

  # GET /api/v1/stats/usage_by_platform
  def usage_by_platform
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      usage_by_platform_data = current_retailer
                              .retailer_amount_messages
                              .range_between(start_date, end_date)
                              .where('retailer_user_id IS NULL')
                              .select("retailer_id, SUM(total_ws_messages) total_ws_messages, SUM(total_msn_messages) total_msn_messages, " \
                                      "SUM(total_ig_messages) total_ig_messages, SUM(total_ml_messages) total_ml_messages")
                              .group("retailer_id")

      if usage_by_platform_data.empty?
        render status: 200, json: { usage_by_platform: {} }
      else
        first_row = usage_by_platform_data[0]
        total_messages = first_row[:total_ws_messages] + first_row[:total_msn_messages] + first_row[:total_ig_messages] + first_row[:total_ml_messages]

        response_data = {
          total_ws_messages: first_row[:total_ws_messages],
          total_msn_messages: first_row[:total_msn_messages],
          total_ig_messages: first_row[:total_ig_messages],
          total_ml_messages: first_row[:total_ml_messages],
          percentage_total_ws_messages: 0,
          percentage_total_msn_messages: 0,
          percentage_total_ig_messages: 0,
          percentage_total_ml_messages: 0
        }

        if total_messages > 0
          response_data[:percentage_total_ws_messages] = ((first_row[:total_ws_messages] * 100).to_f / total_messages).round(2)
          response_data[:percentage_total_msn_messages] = ((first_row[:total_msn_messages] * 100).to_f / total_messages).round(2)
          response_data[:percentage_total_ig_messages] = ((first_row[:total_ig_messages] * 100).to_f / total_messages).round(2)
          response_data[:percentage_total_ml_messages] = ((first_row[:total_ml_messages] * 100).to_f / total_messages).round(2)
        end

        render status: 200, json: { usage_by_platform: response_data }
      end
    else
      render json: { error: "not records" }, status: :not_found
    end
  end

  # GET /api/v1/stats/agent_performance
  def agent_performance
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date]).beginning_of_day
      end_date = Date.parse(params[:end_date]).end_of_day
      platform = params[:platform]

      agent_performance_data = Stats::PerformanceByAgentQuery.new(current_retailer, start_date, end_date, platform).call.to_a

      render status: 200, json: { agent_performance: agent_performance_data }
    else
      render json: { error: "not records" }, status: :not_found
    end
  end

  # GET /api/v1/stats/average_response_times
  def average_response_times
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      if params[:agent].present? && params[:agent] != 'null' &&
         params[:platform].present? && params[:platform] != 'null'
        custom_where = "(retailer_user_id = #{params[:agent]} AND platform = #{params[:platform]})"
      elsif params[:agent].present? && params[:agent] != 'null'
        custom_where = "retailer_user_id = #{params[:agent]}"
      elsif params[:platform].present? && params[:platform] != 'null'
        custom_where = "platform = #{params[:platform]}"
      else
        custom_where = "retailer_user_id IS NOT NULL"
      end

      average_response_times_data = current_retailer
                                    .retailer_average_response_times
                                    .where(custom_where)
                                    .range_between(start_date, end_date)

      render status: 200, json: { average_response_times: average_response_times_data }
    else
      render json: { error: "not records" }, status: :not_found
    end
  end

  # GET /api/v1/stats/most_used_tags
  def most_used_tags
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      most_used_tags_data = current_retailer
                            .retailer_most_used_tags
                            .joins(:tag)
                            .range_between(start_date, end_date)
                            .select("tag_id, tags.tag AS tag_name, SUM(retailer_most_used_tags.amount_used) amount_used")
                            .group("tag_id, tag_name")
                            .order("SUM(amount_used) DESC")

      render status: 200, json: { most_used_tags: most_used_tags_data }
    else
      render json: { error: "not records" }, status: :not_found
    end
  end

  # GET /api/v1/stats/new_and_recurring_conversations
  def new_and_recurring_conversations
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      if params[:agent].present? && params[:agent] != 'null'
        conversations_data = current_retailer
                            .retailer_conversations
                            .where(retailer_user_id: params[:agent])
                            .range_between(start_date, end_date)
      else
        conversations_data = current_retailer
                            .retailer_conversations
                            .where('retailer_user_id IS NULL')
                            .range_between(start_date, end_date)
      end



      render status: 200, json: { conversations_data: conversations_data }
    else
      render json: { error: "not records" }, status: :not_found
    end
  end

  # GET /api/v1/stats/sent_messages_by
  def sent_messages_by
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      sent_messages_data = current_retailer
                          .retailer_amount_messages
                          .joins(:retailer_user)
                          .range_between(start_date, end_date)
                          .where('retailer_user_id IS NOT NULL')
                          .select("retailer_user_id, retailer_users.first_name AS first_name, retailer_users.last_name AS last_name, " \
                                  "SUM(ws_outbound) ws_outbound, SUM(msn_outbound) msn_outbound, SUM(ig_outbound) ig_outbound, SUM(ml_outbound) ml_outbound, "\
                                  "'total_messages' AS total_messages")
                          .group("retailer_user_id, first_name, last_name")

      sent_messages_data.each do |row|
        if params[:platform].present? && params[:platform] != 'null'
          total_messages = 0

          case params[:platform]
          when '0'
            total_messages = row[:ws_outbound]
          when '1'
            total_messages = row[:msn_outbound]
          when '2'
            total_messages = row[:ig_outbound]
          when '3'
            total_messages = row[:ml_outbound]
          end
          row[:total_messages] = total_messages
        else
          row[:total_messages] = row[:ws_outbound] + row[:msn_outbound] + row[:ig_outbound] + row[:ml_outbound]
        end
      end

      render status: 200, json: { sent_messages: sent_messages_data }
    else
      render json: { error: "not records" }, status: :not_found
    end
  end
end