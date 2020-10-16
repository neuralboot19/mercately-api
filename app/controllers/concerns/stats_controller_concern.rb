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
  end

  def total_whatsapp
    @total_inbound_ws = 0
    @total_outbound_ws = 0
    return unless current_retailer.whatsapp_integrated?

    @total_inbound_ws += current_retailer.send(@integration).range_between(@cast_start_date, @cast_end_date)
      .where(direction: 'inbound').where.not(status: @status).size || 0

    @total_outbound_ws += current_retailer.send(@integration).range_between(@cast_start_date, @cast_end_date)
      .where(direction: 'outbound').where.not(status: @status).size || 0
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

    @total_stats_ws = current_retailer.send(@integration).range_between(@cast_start_date, @cast_end_date)
      .group_by_day(:created_at).where.not(status: @status).size

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
end
