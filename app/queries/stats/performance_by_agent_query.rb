module Stats
  class PerformanceByAgentQuery
    def initialize(retailer, start_date, end_date, platform = nil)
      @retailer = retailer
      @start_date = start_date
      @end_date = end_date
      @platform = platform
    end

    def call
      custom_where = case @platform
                    when '0'
                      ' AND customers.ws_active = TRUE'
                    when '1'
                      ' AND customers.pstype = 0'
                    when '2'
                      ' AND customers.pstype = 1'
                    else
                      ''
                    end

      sql_agent_performance = <<-SQL
        SELECT retailer_users.first_name, retailer_users.last_name, tbl_result_2.*,
              (tbl_result_2.amount_chat_in_process + tbl_result_2.amount_chat_resolved) total_chats
        FROM	(
          SELECT retailer_user_id, SUM(CASE WHEN chat_status = 1 THEN 1 ELSE 0 END) amount_chat_in_process,
          SUM(CASE WHEN chat_status = 2 THEN 1 ELSE 0 END) amount_chat_resolved
          FROM (
            SELECT retailer_user_id, customer_id, MAX(chat_histories.created_at) created_at,
              (ARRAY_AGG(chat_status ORDER BY chat_histories.created_at DESC))[1] chat_status
            FROM chat_histories
            INNER JOIN retailer_users ON retailer_users.id = chat_histories.retailer_user_id
            INNER JOIN customers ON customers.id = chat_histories.customer_id
            WHERE retailer_users.retailer_id = :retailer_id AND (chat_status = 1 OR chat_status = 2)
            AND chat_histories.created_at BETWEEN :start_date AND :end_date
            #{custom_where}
            GROUP BY retailer_user_id, customer_id
            ) tbl_result_1
          GROUP BY retailer_user_id
          ) tbl_result_2
        INNER JOIN retailer_users ON retailer_users.id = tbl_result_2.retailer_user_id
        ORDER BY total_chats DESC
      SQL

      ActiveRecord::Base.connection.exec_query(
        ApplicationRecord.sanitize_sql([
          sql_agent_performance, {
            retailer_id: @retailer.id,
            start_date: @start_date,
            end_date: @end_date
          }
        ])
      )
    end
  end
end