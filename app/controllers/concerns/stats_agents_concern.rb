# frozen_string_literal: true

module StatsAgentsConcern
  extend ActiveSupport::Concern

  def total_agents_performance
    total_agent_outbound_messages_ws
    total_agent_outbound_messages_msn
    total_agent_chats_assigned_ws
    total_agent_chats_answered_ws
    total_agent_chats_assigned_msn
    total_agent_chats_answered_msn
    total_customers_ws
    total_customers_msn
    total_agent_stats_msn
    total_agent_stats_ws
    total_agent_stats
  end

  def total_agent_outbound_messages_ws
    @total_agent_messages_ws = {}
    return unless current_retailer.whatsapp_integrated?

    @total_agent_messages_ws = current_retailer.send(@integration)
      .range_between(@cast_start_date, @cast_end_date).where(direction: 'outbound')
      .where.not(where_not).group(:retailer_user_id).count
  end

  def total_agent_outbound_messages_msn
    @total_agent_messages_msn = {}
    return unless current_retailer.facebook_retailer&.connected?

    @total_agent_messages_msn = current_retailer.facebook_retailer.facebook_messages
      .range_between(@cast_start_date, @cast_end_date)
      .where(sent_by_retailer: true)
      .where.not(retailer_user_id: nil, note: true)
      .group(:retailer_user_id).count
  end

  def total_agent_chats_assigned_ws
    @total_agent_chats_assigned_ws = {}
    return unless current_retailer.whatsapp_integrated?

    wherenot = if current_retailer.karix_integrated?
                 { status: @status }
               else
                 { status: @status, note: true }
               end
    # query que lista todos los chat que fueron asignados - WHATSAAP
    @total_agent_chats_assigned_ws = AgentCustomer.where(retailer_user_id: current_retailer.retailer_users.ids)
      .where(customer_id: current_retailer.send(@integration).where.not(wherenot).select(:customer_id).distinct)
      .update_range_between(@cast_start_date, @cast_end_date).group(:retailer_user_id).count
  end

  def total_agent_chats_answered_ws
    @total_agent_chats_answered_ws = {}
    return unless current_retailer.whatsapp_integrated?

    # query que lista todos los chat asignados y que fueron respondidos - WHATSAAP
    @total_agent_chats_answered_ws = AgentCustomer.where(retailer_user_id: current_retailer.retailer_users.ids)
      .where(customer_id: current_retailer.send(@integration).range_between(@cast_start_date,@cast_end_date).where.not(where_not)
      .where(direction: 'outbound', message_type: 'conversation').select(:customer_id).distinct)
      .update_range_between(@cast_start_date, @cast_end_date).group(:retailer_user_id).count
  end

  def total_agent_chats_assigned_msn
    @total_agent_chats_assigned_msn = {}
    return unless current_retailer.facebook_retailer&.connected?

    # query que lista todos los chat que fueron asignados - MSN
    @total_agent_chats_assigned_msn = AgentCustomer.where(retailer_user_id: current_retailer.retailer_users.ids)
      .where(customer_id: current_retailer.facebook_retailer.facebook_messages.where.not(note: true).select(:customer_id).distinct)
      .update_range_between(@cast_start_date, @cast_end_date).group(:retailer_user_id).count

  end

  def total_agent_chats_answered_msn
    @total_agent_chats_answered_msn = {}
    return unless current_retailer.facebook_retailer&.connected?

    # query que lista todos los chat que fueron asignados - y respondidos MSN
    @total_agent_chats_answered_msn = AgentCustomer.where(retailer_user_id: current_retailer.retailer_users.ids)
      .where(customer_id: current_retailer.facebook_retailer.facebook_messages.range_between(@cast_start_date,@cast_end_date)
      .where(sent_by_retailer: true).where.not(retailer_user_id: nil, note: true).select(:customer_id).distinct)
      .update_range_between(@cast_start_date, @cast_end_date).group(:retailer_user_id).count

  end

  def total_customers_ws
    @total_agent_currents_ws = {}
    @total_agent_prospects_ws = {}
    return unless current_retailer.whatsapp_integrated?

    customers = current_retailer.customers.includes(@integration.to_sym)
      .where("#{@integration}.created_at >= ? and #{@integration}.created_at <= ? and " \
      'direction = ?', @cast_start_date, @cast_end_date, 'outbound')
      .where.not(@integration.to_sym => where_not)
      .select("customers.*, #{@integration}.retailer_user_id")

    @total_agent_prospects_ws = customers.range_between(@cast_start_date, @cast_end_date).group(:retailer_user_id)
      .count('distinct customers.id')
    @total_agent_currents_ws = customers.out_of_range(@cast_start_date, @cast_end_date).group(:retailer_user_id)
      .count('distinct customers.id')
  end

  def total_customers_msn
    @total_agent_currents_msn = {}
    @total_agent_prospects_msn = {}
    return unless current_retailer.facebook_retailer&.connected?

    customers = current_retailer.customers.includes(:facebook_messages)
      .where('facebook_messages.created_at >= ? and facebook_messages.created_at <= ?',
             @cast_start_date, @cast_end_date)
      .where(facebook_messages: { sent_by_retailer: true })
      .where.not(facebook_messages: { retailer_user_id: nil, note: true })
      .select('customers.*, facebook_messages.retailer_user_id')

    @total_agent_prospects_msn = customers.range_between(@cast_start_date, @cast_end_date).group(:retailer_user_id)
      .count('distinct customers.id')
    @total_agent_currents_msn = customers.out_of_range(@cast_start_date, @cast_end_date).group(:retailer_user_id)
      .count('distinct customers.id')
  end

  def total_agent_stats_msn
    @agent_stats_msn = []
    return if agents_ids_msn.blank?

    current_retailer.retailer_users.where(id: agents_ids_msn).find_each do |ru|
      id = ru.id
      @agent_stats_msn << {
        name: ru.full_name.presence || ru.email,
        chats_assigned: @total_agent_chats_assigned_msn[id] || 0,
        chats_answered: @total_agent_chats_answered_msn[id] || 0,
        chats_not_answered: (@total_agent_chats_assigned_msn[id] || 0 ) - (@total_agent_chats_answered_msn[id] || 0),
        messages_sent: @total_agent_messages_msn[id] || 0,
        customers: agent_total_customers_msn(id),
        prospects: @total_agent_prospects_msn[id] || 0,
        currents: @total_agent_currents_msn[id] || 0
      }
    end
  end

  def agents_ids_msn
    (@total_agent_messages_msn.keys + @total_agent_currents_msn.keys + @total_agent_chats_assigned_msn.keys +
      @total_agent_prospects_msn.keys).compact.uniq
  end

  def agent_total_customers_msn(id)
    (@total_agent_currents_msn[id] || 0) + (@total_agent_prospects_msn[id] || 0)
  end

  def total_agent_stats_ws
    @agent_stats_ws = []
    return if agents_ids_ws.blank?

    current_retailer.retailer_users.where(id: agents_ids_ws).find_each do |ru|
      id = ru.id
      @agent_stats_ws << {
        name: ru.full_name.presence || ru.email,
        chats_assigned: @total_agent_chats_assigned_ws[id] || 0,
        chats_answered: @total_agent_chats_answered_ws[id] || 0,
        chats_not_answered: (@total_agent_chats_assigned_ws[id] || 0) - (@total_agent_chats_answered_ws[id] || 0),
        messages_sent: @total_agent_messages_ws[id] || 0,
        customers: agent_total_customers_ws(id),
        prospects: @total_agent_prospects_ws[id] || 0,
        currents: @total_agent_currents_ws[id] || 0
      }
    end
  end

  def agents_ids_ws
    (@total_agent_messages_ws.keys + @total_agent_currents_ws.keys + @total_agent_chats_assigned_ws.keys +
      @total_agent_prospects_ws.keys).compact.uniq
  end

  def agent_total_customers_ws(id)
    (@total_agent_currents_ws[id] || 0) + (@total_agent_prospects_ws[id] || 0)
  end


  def total_agent_stats
    @agent_stats = []
    return if agents_ids.blank?

    current_retailer.retailer_users.where(id: agents_ids).find_each do |ru|
      id = ru.id
      @agent_stats << {
        name: ru.full_name.presence || ru.email,
        chats_assigned: (@total_agent_chats_assigned_msn[id] || 0) + (@total_agent_chats_assigned_ws[id] || 0),
        chats_answered: (@total_agent_chats_answered_msn[id] || 0) + (@total_agent_chats_answered_ws[id] || 0),
        chats_not_answered: total_chats_not_answered(id),
        messages_sent: (@total_agent_messages_msn[id] || 0) + (@total_agent_messages_ws[id] || 0),
        customers: agent_total_customers_msn(id) + agent_total_customers_ws(id),
        prospects: (@total_agent_prospects_msn[id] || 0) + (@total_agent_prospects_ws[id] || 0),
        currents: (@total_agent_currents_msn[id] || 0) + (@total_agent_currents_ws[id] || 0)
      }
    end
  end

  def agents_ids
    (@total_agent_messages_ws.keys + @total_agent_currents_ws.keys +  @total_agent_chats_assigned_ws.keys + @total_agent_prospects_ws.keys +
      @total_agent_messages_msn.keys + @total_agent_currents_msn.keys + @total_agent_chats_assigned_msn.keys + @total_agent_prospects_msn.keys
    ).compact.uniq
  end

  def total_chats_not_answered(id)
    ((@total_agent_chats_assigned_msn[id] || 0 ) - (@total_agent_chats_answered_msn[id] || 0)) +
      ((@total_agent_chats_assigned_ws[id] || 0 ) - (@total_agent_chats_answered_ws[id] || 0))
  end

  def where_not
    if current_retailer.karix_integrated?
      { status: @status, retailer_user_id: nil }
    else
      { status: @status, retailer_user_id: nil, note: true }
    end
  end
end
