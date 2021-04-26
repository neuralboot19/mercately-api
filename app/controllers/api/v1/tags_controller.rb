# frozen_string_literal: true

class Api::V1::TagsController < Api::ApiController
  include CurrentRetailer

  # GET /api/v1/tags
  def index
    params[:q]&.delete_if { |_k, v| v == 'none' }
    @filter = current_retailer.tags.ransack(params[:q])
    @tags = @filter.result
    @tags = @tags.map { |tag| { value: tag.id, label: tag.tag } }
    render status: 200, json: { tags: @tags }
  end
end
