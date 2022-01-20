module Stats
  class PerformanceByAgentQuery
    def initialize(retailer, start_date, end_date)
      @retailer = retailer
      @start_date = start_date
      @end_date = end_date
    end

    def call
      sql_agent_performance = <<-SQL
        SELECT retailer_users.first_name, retailer_users.last_name, tbl_result_2.*
        FROM	(
          SELECT retailer_user_id, SUM(CASE WHEN chat_status = 1 THEN 1 ELSE 0 END) amount_chat_in_process,
          SUM(CASE WHEN chat_status = 2 THEN 1 ELSE 0 END) amount_chat_resolved
          FROM (
            SELECT retailer_user_id, customer_id, MAX(chat_histories.created_at) created_at,
              (ARRAY_AGG(chat_status ORDER BY chat_histories.created_at DESC))[1] chat_status
            FROM chat_histories
            INNER JOIN retailer_users ON retailer_users.id = chat_histories.retailer_user_id
            WHERE retailer_users.retailer_id = :retailer_id AND (chat_status = 1 OR chat_status = 2)
            AND chat_histories.created_at BETWEEN :start_date AND :end_date
            GROUP BY retailer_user_id, customer_id
            ) tbl_result_1
          GROUP BY retailer_user_id
          ) tbl_result_2
        INNER JOIN retailer_users ON retailer_users.id = tbl_result_2.retailer_user_id
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