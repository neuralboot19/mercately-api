# frozen_string_literal: true

module StatsProspectsConcern
  extend ActiveSupport::Concern

  def total_prospects_vs_currents
    prospects_vs_currents_ws
    prospects_vs_currents_msn
    prospects_vs_currents_ml
    total_percentage
  end

  def prospects_vs_currents_ws
    @ws_currents = 0
    @ws_prospects = 0
    return unless current_retailer.whatsapp_integrated?

    customers = current_retailer.customers.includes(@integration.to_sym)
      .where("#{@integration}.created_at >= ? and #{@integration}.created_at <= ? and " \
      'direction = ?', @cast_start_date, @cast_end_date, 'inbound')
      .where.not(@integration.to_sym => { status: @status })

    @ws_prospects = customers.range_between(@cast_start_date, @cast_end_date).size
    @ws_currents = customers.out_of_range(@cast_start_date, @cast_end_date).size
  end

  def prospects_vs_currents_msn
    @msn_currents = 0
    @msn_prospects = 0
    return unless current_retailer.facebook_retailer&.connected?

    customers = current_retailer.customers.includes(:facebook_messages)
      .where('facebook_messages.created_at >= ? and facebook_messages.created_at <= ?',
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
        .where('questions.created_at >= ? and questions.created_at <= ?',
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

    return unless total.positive?

    @percentage_prospects = (total_prospects / total.to_f * 100).round(2)
    @percentage_currents = (total_currents / total.to_f * 100).round(2)
  end
end
