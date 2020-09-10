# frozen_string_literal: true

module StatsControllerConcern
  extend ActiveSupport::Concern

  def total_count_messages
    total_whatsapp
    total_messenger
    total_ml

    @total_inbound = @total_inbound_ws + @total_inbound_msn + @total_inbound_ml
    @total_outbound = @total_outbound_ws + @total_outbound_msn + @total_outbound_ml
    @total_stats = []

    total_stats_ws
    total_stats_msn
    total_stats_ml
    total_stats

    prospects_vs_currents_ws
    prospects_vs_currents_msn
    prospects_vs_currents_ml
    total_percentage
  end

  def total_whatsapp
    @total_inbound_ws = 0
    @total_outbound_ws = 0
    return unless current_retailer.whatsapp_integrated?

    @total_inbound_ws += if current_retailer.karix_integrated?
                           current_retailer.karix_whatsapp_messages.range_between(@cast_start_date, @cast_end_date)
                           .where(direction: 'inbound').where.not(status: 'failed').size || 0
                         elsif current_retailer.gupshup_integrated?
                           current_retailer.gupshup_whatsapp_messages.range_between(@cast_start_date, @cast_end_date)
                           .where(direction: 'inbound').where.not(status: 'error').size || 0
                         end

    @total_outbound_ws += if current_retailer.karix_integrated?
                            current_retailer.karix_whatsapp_messages.range_between(@cast_start_date, @cast_end_date)
                            .where(direction: 'outbound').where.not(status: 'failed').size || 0
                          elsif current_retailer.gupshup_integrated?
                            current_retailer.gupshup_whatsapp_messages.range_between(@cast_start_date, @cast_end_date)
                            .where(direction: 'outbound').where.not(status: 'error').size || 0
                          end
  end

  def total_messenger
    @total_inbound_msn = 0
    @total_outbound_msn = 0
    return unless current_retailer.facebook_retailer&.connected?

    @total_inbound_msn += current_retailer.facebook_retailer.facebook_messages
      .range_between(@cast_start_date, @cast_end_date).where(sent_by_retailer: false).size || 0

    @total_outbound_msn += current_retailer.facebook_retailer.facebook_messages
      .range_between(@cast_start_date, @cast_end_date).where(sent_by_retailer: true).size || 0
  end

  def total_ml
    @total_inbound_ml = 0
    @total_outbound_ml = 0
    return unless current_retailer.meli_retailer

    @total_inbound_ml += Question.unscoped.range_between(@cast_start_date, @cast_end_date)
      .includes(:customer).where(customers: { retailer_id: current_retailer.id }).where.not(question: [nil, '']).size

    @total_outbound_ml += Question.unscoped.range_between(@cast_start_date, @cast_end_date)
      .includes(:customer).where(customers: { retailer_id: current_retailer.id }).where.not(answer: [nil, '']).size
  end

  def total_stats_ws
    @total_stats_ws = {}
    return unless current_retailer.whatsapp_integrated?

    @total_stats_ws = if current_retailer.karix_integrated?
                        current_retailer.karix_whatsapp_messages.range_between(@cast_start_date, @cast_end_date)
                        .group_by_day(:created_at).where.not(status: 'failed').size
                      elsif current_retailer.gupshup_integrated?
                        current_retailer.gupshup_whatsapp_messages.range_between(@cast_start_date, @cast_end_date)
                        .group_by_day(:created_at).where.not(status: 'error').size
                      end

    @total_stats << {
      name: 'Whatsapp',
      data: @total_stats_ws,
      color: '#00B555'
    }
  end

  def total_stats_msn
    @total_stats_msn = {}
    return unless current_retailer.facebook_retailer&.connected?

    @total_stats_msn = current_retailer.facebook_retailer.facebook_messages.range_between(@cast_start_date, @cast_end_date)
      .group_by_day(:created_at).size

    @total_stats << {
      name: 'Messenger',
      data: @total_stats_msn,
      color: '#39B4E6'
    }
  end

  def total_stats_ml
    @total_stats_ml = {}
    return unless current_retailer.meli_retailer

    @total_stats_ml = Question.unscoped.includes(:customer).where(customers: { retailer_id: current_retailer.id })
      .range_between(@cast_start_date, @cast_end_date).group_by_day(:created_at).size

    @total_stats << {
      name: 'MercadoLibre',
      data: @total_stats_ml,
      color: '#FFEC00'
    }
  end

  def total_stats
    dates_list = (@total_stats_ws.keys + @total_stats_msn.keys + @total_stats_ml.keys).uniq.sort
    stats = {}

    dates_list.each do |dl|
      stats[dl] = 0

      @total_stats_ws.key?(dl) ? stats[dl] += @total_stats_ws[dl] : @total_stats_ws[dl] = 0
      @total_stats_msn.key?(dl) ? stats[dl] += @total_stats_msn[dl] : @total_stats_msn[dl] = 0
      @total_stats_ml.key?(dl) ? stats[dl] += @total_stats_ml[dl] : @total_stats_ml[dl] = 0
    end

    @total_stats << {
      name: 'Total',
      data: stats,
      color: '#6B2288'
    }
  end

  def prospects_vs_currents_ws
    @ws_currents = 0
    @ws_prospects = 0
    return unless current_retailer.whatsapp_integrated?

    customers = if current_retailer.karix_integrated?
                  current_retailer.customers.includes(:karix_whatsapp_messages)
                  .where("karix_whatsapp_messages.created_at >= ? and karix_whatsapp_messages.created_at <= ? and " \
                  "direction = ?", @cast_start_date, @cast_end_date, 'inbound')
                  .where.not(karix_whatsapp_messages: { status: 'failed' })
                elsif current_retailer.gupshup_integrated?
                  current_retailer.customers.includes(:gupshup_whatsapp_messages)
                  .where("gupshup_whatsapp_messages.created_at >= ? and gupshup_whatsapp_messages.created_at <= ? " \
                  "and direction = ?", @cast_start_date, @cast_end_date, 'inbound')
                  .where.not(gupshup_whatsapp_messages: { status: 'error' })
                end

    @ws_prospects = customers.range_between(@cast_start_date, @cast_end_date).size
    @ws_currents = customers.out_of_range(@cast_start_date, @cast_end_date).size
  end

  def prospects_vs_currents_msn
    @msn_currents = 0
    @msn_prospects = 0
    return unless current_retailer.facebook_retailer&.connected?

    customers = current_retailer.customers.includes(:facebook_messages)
      .where("facebook_messages.created_at >= ? and facebook_messages.created_at <= ?",
      @cast_start_date, @cast_end_date)
      .where(facebook_messages: { sent_by_retailer: false })

    @msn_prospects = customers.range_between(@cast_start_date, @cast_end_date).size
    @msn_currents = customers.out_of_range(@cast_start_date, @cast_end_date).size
  end

  def prospects_vs_currents_ml
    @ml_currents = 0
    @ml_prospects = 0
    return unless current_retailer.meli_retailer

    Question.unscoped do
      customers = current_retailer.customers.includes(:questions)
        .where("questions.created_at >= ? and questions.created_at <= ?",
        @cast_start_date, @cast_end_date)
        .where.not(questions: { question: [nil, ''] })

      @ml_prospects = customers.range_between(@cast_start_date, @cast_end_date).size
      @ml_currents = customers.out_of_range(@cast_start_date, @cast_end_date).size
    end
  end

  def total_percentage
    total_prospects = @ws_prospects + @msn_prospects + @ml_prospects
    total_currents = @ws_currents + @msn_currents + @ml_currents
    total = total_prospects + total_currents
    @percentage_prospects = 0.0
    @percentage_currents = 0.0

    return unless total > 0

    @percentage_prospects = (total_prospects.to_f / total.to_f * 100).round(2)
    @percentage_currents = (total_currents.to_f / total.to_f * 100).round(2)
  end
end
