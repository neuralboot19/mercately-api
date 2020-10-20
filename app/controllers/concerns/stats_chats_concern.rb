# frozen_string_literal: true

module StatsChatsConcern
  extend ActiveSupport::Concern

  def total_chats_answered
    total_chats_ws
    total_chats_answered_ws
    total_chats_msn
    total_chats_answered_msn

    @total_chats = [
      {
        platform: 'Whatsapp',
        total_chats: @total_ws,
        total_answered: @total_answered_ws,
        total_not_answered: @total_ws - @total_answered_ws
      },
      {
        platform: 'Messenger',
        total_chats: @total_msn,
        total_answered: @total_answered_msn,
        total_not_answered: @total_msn - @total_answered_msn
      },
      {
        platform: 'TOTAL',
        total_chats: @total_ws + @total_msn,
        total_answered: @total_answered_ws + @total_answered_msn,
        total_not_answered: (@total_ws - @total_answered_ws) + (@total_msn - @total_answered_msn)
      }
    ]
  end

  private

    def total_chats_ws
      @total_ws = 0
      return unless current_retailer.whatsapp_integrated?

      sql = "select count(*) from #{@integration} gsm1 where " \
        "DATE_PART('day', COALESCE((select gsm2.created_at from #{@integration} gsm2 " \
        'where gsm2.created_at > gsm1.created_at and gsm2.customer_id = gsm1.customer_id and ' \
        "gsm2.direction = 'inbound' order by gsm2.created_at limit 1), ?)::timestamp - " \
        "gsm1.created_at::timestamp) >= 1 and gsm1.retailer_id = #{current_retailer.id} and " \
        "gsm1.direction = 'inbound' and gsm1.created_at >= ? and " \
        'gsm1.created_at <= ?'

      @total_ws = @model.count_by_sql([sql, @cast_end_date, @cast_start_date, @cast_end_date])
    end

    def total_chats_answered_ws
      @total_answered_ws = 0
      return unless current_retailer.whatsapp_integrated?

      sql = 'select count(*) from (select t1.customer_id, t1.created_date, ' \
        'COALESCE(lag(t1.created_date) over(partition by t1.customer_id order by t1.created_date), ' \
        '?) prev_date from (select gsm1.customer_id, ' \
        "gsm1.created_at + '24 hours'::interval as created_date from #{@integration} gsm1 " \
        "where DATE_PART('day', COALESCE((select gsm2.created_at from #{@integration} gsm2 " \
        'where gsm2.created_at > gsm1.created_at and gsm2.customer_id = gsm1.customer_id and ' \
        "gsm2.direction = 'inbound' order by gsm2.created_at limit 1), ?)::timestamp - " \
        'gsm1.created_at::timestamp) >= 1 ' \
        "and gsm1.retailer_id = #{current_retailer.id} and gsm1.direction = 'inbound' " \
        'and gsm1.created_at >= ? and gsm1.created_at <= ? ' \
        'group by gsm1.customer_id, gsm1.created_at ' \
        'order by gsm1.created_at) t1) t2 ' \
        "where (select id from #{@integration} gsm3 " \
        "where gsm3.direction = 'outbound' and gsm3.retailer_user_id is not null and " \
        "gsm3.message_type = 'conversation' and gsm3.customer_id = t2.customer_id and " \
        'gsm3.created_at > t2.prev_date and gsm3.created_at < t2.created_date limit 1) is not null'

      @total_answered_ws = @model.count_by_sql(
        [
          sql, @cast_start_date, @cast_end_date, @cast_start_date, @cast_end_date
        ]
      )
    end

    def total_chats_msn
      @total_msn = 0
      return unless current_retailer.facebook_retailer&.connected?

      sql = 'select count(*) from facebook_messages fm1 where ' \
        "DATE_PART('day', COALESCE((select fm2.created_at from facebook_messages fm2 " \
        'where fm2.created_at > fm1.created_at and fm2.customer_id = fm1.customer_id and ' \
        'fm2.sent_by_retailer = false order by fm2.created_at limit 1), ?)::timestamp - ' \
        "fm1.created_at::timestamp) >= 1 and fm1.facebook_retailer_id = #{current_retailer.facebook_retailer.id} " \
        'and fm1.sent_by_retailer = false and fm1.created_at >= ? and ' \
        'fm1.created_at <= ?'

      @total_msn = FacebookMessage.count_by_sql([sql, @cast_end_date, @cast_start_date, @cast_end_date])
    end

    def total_chats_answered_msn
      @total_answered_msn = 0
      return unless current_retailer.facebook_retailer&.connected?

      sql = 'select count(*) from (select t1.customer_id, t1.created_date, ' \
        'COALESCE(lag(t1.created_date) over(partition by t1.customer_id order by t1.created_date), ' \
        '?) prev_date from (select fm1.customer_id, ' \
        "fm1.created_at + '24 hours'::interval as created_date from facebook_messages fm1 " \
        "where DATE_PART('day', COALESCE((select fm2.created_at from facebook_messages fm2 " \
        'where fm2.created_at > fm1.created_at and fm2.customer_id = fm1.customer_id and ' \
        'fm2.sent_by_retailer = false order by fm2.created_at limit 1), ?)::timestamp - ' \
        'fm1.created_at::timestamp) >= 1 ' \
        "and fm1.facebook_retailer_id = #{current_retailer.facebook_retailer.id} and fm1.sent_by_retailer = false " \
        'and fm1.created_at >= ? and fm1.created_at <= ? ' \
        'group by fm1.customer_id, fm1.created_at ' \
        'order by fm1.created_at) t1) t2 ' \
        'where (select id from facebook_messages fm3 ' \
        'where fm3.sent_by_retailer = true and fm3.retailer_user_id is not null and ' \
        'fm3.customer_id = t2.customer_id and ' \
        'fm3.created_at > t2.prev_date and fm3.created_at < t2.created_date limit 1) is not null'

      @total_answered_msn = FacebookMessage.count_by_sql(
        [
          sql, @cast_start_date, @cast_end_date, @cast_start_date, @cast_end_date
        ]
      )
    end
end
