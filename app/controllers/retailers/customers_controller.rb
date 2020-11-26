# frozen_string_literal: true

class Retailers::CustomersController < RetailersController
  include CustomerControllerConcern
  before_action :check_ownership, only: [:show, :edit, :update, :destroy]
  before_action :set_customer, only: [:show, :edit, :update, :destroy]
  before_action :load_tags, only: [:new, :edit, :create, :update]
  before_action :save_new_tags, only: [:create, :update]
  before_action :validate_permissions, only: [
    :show, :edit, :update, :destroy, :import, :bulk_import
  ]

  def index
    @filter = build_ransack_query
    @customers = @filter.result.page(params[:page])

    ActiveRecord::Precounter.new(@customers).precount(:orders_pending, :orders_success, :orders_cancelled)
    @export_params = export_params
  end

  def export
    Customers::ExportCustomersJob.perform_later(current_retailer_user.id, export_params)

    redirect_to(retailers_customers_path(current_retailer, q: { 's': 'created_at desc' }),
                notice: 'La exportación está en proceso, recibirá un mail cuando esté lista.')
  end

  def import
  end

  def bulk_import
    notice = 'Debe seleccionar un archivo'

    if import_params['csv_file'].present?
      results = Customer.csv_import!(current_retailer, import_params['csv_file'])

      notice = ['La importación se realizó con éxito']
      notice = results[:body][:errors].flatten if results[:status] != :ok
    end

    redirect_to(
      retailers_customers_import_path(current_retailer),
      notice: notice
    )
  end

  def show
  end

  def new
    @customer = Customer.new
  end

  def edit
    edit_setup
  end

  def create
    @customer = Customer.new(customer_params)
    @customer.retailer_id = @retailer.id

    if @customer.save
      redirect_to retailers_customers_path(@retailer, q: { 's': 'created_at desc' }), notice:
        'Cliente creado con éxito.'
    else
      flash[:notice] = @customer.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    if @customer.update(customer_params)
      redirect_to retailers_customers_path(@retailer, q: { 's': 'created_at desc' }), notice:
        'Cliente actualizado con éxito.'
    else
      flash[:notice] = @customer.errors.full_messages.join(', ')
      render :edit
    end
  end

  def customer_data
    @customer = current_retailer.customers.active.find(params[:id])

    render json: { customer: @customer }
  end

  private

    def check_ownership
      customer = Customer.find_by(web_id: params[:id])
      redirect_to retailers_dashboard_path(@retailer) unless customer && @retailer.customers.exists?(customer.id)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find_by(web_id: params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def customer_params
      params.require(:customer).permit(
        :email,
        :phone,
        :id_type,
        :id_number,
        :address,
        :city,
        :state,
        :zip_code,
        :country_id,
        :first_name,
        :last_name,
        :notes,
        :send_for_opt_in,
        tag_ids: []
      )
    end

    def export_params
      params.permit(
        q: [
          :first_name_or_last_name_or_phone_or_email_or_whatsapp_name_cont,
          :s,
          :agent_id,
          customer_tags_tag_id_in: []
        ]
      )
    end

    def import_params
      params.permit(:csv_file)
    end

    def load_tags
      @tags = current_retailer.available_customer_tags(@customer&.id) || []
    end

    def save_new_tags
      return unless params[:customer][:tag_ids].present?

      new_tag_ids = []
      params[:customer][:tag_ids].each do |tag|
        next unless tag.present?

        unless tag.to_i.zero?
          new_tag_ids << tag
          next
        end

        new_tag = current_retailer.tags.create(tag: tag)
        new_tag_ids << new_tag&.id
      end

      params[:customer][:tag_ids] = new_tag_ids.compact
    end

    def validate_permissions
      return unless current_retailer_user.agent?
      return if params[:action] != 'import' && permissions?

      flash[:notice] = 'Disculpe, no posee permisos para ver esta página'
      redirect_to retailers_customers_path params: {
        slug: current_retailer.slug,
        q: { 's': 'created_at desc' }
      }
    end

    def permissions?
      return true unless @customer.agent.present?

      @customer.agent_customer.retailer_user_id == current_retailer_user.id
    end

    def agent_ids
      # An agent is filtering by agent_id, so, will filter
      # only by the current logged in agent
      agent_filtering = current_retailer_user.agent? && params[:q]&.[](:agent_id).present?
      return [current_retailer_user.id] if agent_filtering

      # An agent is not filtering by agent_id, so, needed to
      # the default filter to be prepared
      agent_not_filtering = current_retailer_user.agent? && !params[:q]&.[](:agent_id).present?
      return [current_retailer_user.id, nil] if agent_not_filtering

      # An admin is filtering by agent_id
      [params[:q]&.[](:agent_id)]
    end

    def filtering_by_agent?
      current_retailer_user.agent? || params[:q]&.[](:agent_id).present?
    end

    def filtered_customers
      customers = Customer.eager_load(:orders_success)
        .active
        .where(retailer_id: current_retailer.id)

      if filtering_by_agent?
        customers = customers.left_outer_joins(:agent_customer)
          .where(agent_customers: {
            retailer_user_id: agent_ids
          })
      end

      customers
    end

    def build_ransack_query
      return filtered_customers.ransack(params[:q]) unless params[:q]&.[](:s).blank?

      filtered_customers.order(created_at: :desc).ransack(params[:q])
    end
end
