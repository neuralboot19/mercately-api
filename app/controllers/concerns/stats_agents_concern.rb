# frozen_string_literal: true

module StatsAgentsConcern
  extend ActiveSupport::Concern

  def total_agents_performance
    @integration, @status = if current_retailer.karix_integrated?
                              ['karix_whatsapp_messages', 'failed']
                            elsif current_retailer.gupshup_integrated?
                              ['gupshup_whatsapp_messages', 'error']
                            end

    total_agent_outbound_messages_ws
    total_agent_outbound_messages_msn
    total_agent_chats_assigned
    total_customers_ws
    total_customers_msn
    total_agent_stats
  end

  def total_agent_outbound_messages_ws
    @total_agent_messages_ws = {}
    return unless current_retailer.whatsapp_integrated?

    @total_agent_messages_ws = current_retailer.send(@integration)
      .range_between(@cast_start_date, @cast_end_date).where(direction: 'outbound')
      .where.not(status: @status, retailer_user_id: nil).group(:retailer_user_id).count
  end

  def total_agent_outbound_messages_msn
    @total_agent_messages_msn = {}
    return unless current_retailer.facebook_retailer&.connected?

    @total_agent_messages_msn = current_retailer.facebook_retailer.facebook_messages
      .range_between(@cast_start_date, @cast_end_date).where(sent_by_retailer: true).where.not(retailer_user_id: nil)
      .group(:retailer_user_id).count
  end

  def total_agent_chats_assigned
    @total_agent_chats = AgentCustomer.where(retailer_user_id: current_retailer.retailer_users.ids)
      .update_range_between(@cast_start_date, @cast_end_date).group(:retailer_user_id).count
  end

  def total_customers_ws
    @total_agent_currents_ws = {}
    @total_agent_prospects_ws = {}
    return unless current_retailer.whatsapp_integrated?

    customers = current_retailer.customers.includes(@integration.to_sym)
      .where("#{@integration}.created_at >= ? and #{@integration}.created_at <= ? and " \
      'direction = ?', @cast_start_date, @cast_end_date, 'outbound')
      .where.not(@integration.to_sym => { status: @status, retailer_user_id: nil })
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
      .where.not(facebook_messages: { retailer_user_id: nil })
      .select('customers.*, facebook_messages.retailer_user_id')

    @total_agent_prospects_msn = customers.range_between(@cast_start_date, @cast_end_date).group(:retailer_user_id)
      .count('distinct customers.id')
    @total_agent_currents_msn = customers.out_of_range(@cast_start_date, @cast_end_date).group(:retailer_user_id)
      .count('distinct customers.id')
  end

  def total_agent_stats
    agents = current_retailer.retailer_users
    @agent_stats = []

    agents_ids.each do |id|
      ru = agents.map { |ag| ag if ag.id == id }.compact.first

      @agent_stats << {
        name: ru.full_name.presence || ru.email,
        chats_assigned: @total_agent_chats[id] || 0,
        messages_sent: total_messages_sent(id),
        customers: agent_total_customers(id),
        prospects: total_prospects_customers(id),
        currents: total_currents_customers(id)
      }
    end
  end

  def agents_ids
    (@total_agent_messages_ws.keys + @total_agent_messages_msn.keys + @total_agent_chats.keys +
      @total_agent_currents_ws.keys + @total_agent_prospects_ws.keys + @total_agent_currents_msn.keys +
      @total_agent_prospects_msn.keys).compact.uniq
  end

  def agent_total_customers(id)
    (@total_agent_currents_ws[id] || 0) + (@total_agent_prospects_ws[id] || 0) +
      (@total_agent_currents_msn[id] || 0) + (@total_agent_prospects_msn[id] || 0)
  end

  def total_messages_sent(id)
    (@total_agent_messages_ws[id] || 0) + (@total_agent_messages_msn[id] || 0)
  end

  def total_prospects_customers(id)
    (@total_agent_prospects_ws[id] || 0) + (@total_agent_prospects_msn[id] || 0)
  end

  def total_currents_customers(id)
    (@total_agent_currents_ws[id] || 0) + (@total_agent_currents_msn[id] || 0)
  end
end
