# frozen_string_literal: true

class Api::V1::ContactGroupsController < Api::ApiController
  include CurrentRetailer

  before_action :set_contact_group, except: %i[customers create]

  # GET /api/v1/contact_groups/customers
  def customers
    params[:q]&.delete_if { |_k, v| v == 'none' }
    @filter = current_retailer.customers.includes(:tags).active.ransack(params[:q])
    @customers = @filter.result.order(created_at: :desc).page(params[:page]).per(15)
    total_pages = @customers&.total_pages
    render status: 200, json: {
      customers: @customers.as_json(methods: [:name, :tags]),
      total_customers: total_pages
    }
  end

  # GET /api/v1/contact_groups/:id/selected_customers
  def selected_customers
    params[:q]&.delete_if { |_k, v| v == 'none' }
    @filter = @contact_group.customers.includes(:tags).ransack(params[:q])
    @customers = @filter.result.order(created_at: :desc).page(params[:page]).per(15)
    total_pages = @customers&.total_pages
    render status: 200, json: {
      name: @contact_group.name,
      customers: @customers.as_json(methods: [:name, :tags]),
      customer_ids: @customers.ids.map(&:to_s),
      total_customers: total_pages
    }
  end

  # POST /api/v1/contact_groups
  def create
    @contact_group = current_retailer.contact_groups.new(contact_group_params)

    if @contact_group.save
      render status: 200, json: { contact_group: @contact_group }
    else
      render status: 400, json: { contact_group: @contact_group, errors: @contact_group.errors }
    end
  end

  # PUT /api/v1/contact_groups/:id
  def update
    if @contact_group.update(contact_group_params)
      render status: 200, json: { contact_group: @contact_group }
    else
      render status: 400, json: { contact_group: @contact_group, errors: @contact_group.errors }
    end
  end

  private

    def set_contact_group
      @contact_group = ContactGroup.find_by(web_id: params[:id]) || not_found
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end

    def contact_group_params
      params.require(:contact_group).permit(
        :name,
        customer_ids: []
      )
    end
end
