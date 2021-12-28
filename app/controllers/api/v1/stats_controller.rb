class Api::V1::StatsController < Api::ApiController
  include CurrentRetailer

  # GET /api/v1/stats/agent_performance
  def agent_performance
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date]).beginning_of_day
      end_date = Date.parse(params[:end_date]).end_of_day

      agent_performance = Stats::PerformanceByAgentQuery.new(current_retailer, start_date, end_date).call.to_a

      render status: 200, json: { agent_performance: agent_performance }
    else
      render json: { error: "not records" }, status: :not_found
    end
  end
end