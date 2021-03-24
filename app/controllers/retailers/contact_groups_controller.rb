# frozen_string_literal: true

class Retailers::ContactGroupsController < RetailersController
  before_action :set_contact_group, only: %i[edit archive destroy import_update bulk_update]
  before_action :check_customers, only: %i[index new]
  before_action :whatsapp_integrated?, only: %i[index new]

  # GET retailers/:slug/contact_groups
  def index
    params[:q]&.delete_if { |_k, v| v == 'none' }
    @filter = current_retailer.contact_groups.includes(:customers).not_archived.ransack(params[:q])
    @contact_groups = @filter.result.order(created_at: :desc).page(params[:page])
  end

  # GET retailers/:slug/contact_groups/new
  def new
  end

  # GET retailers/:slug/contact_groups/:id/edit
  def edit
  end

  # GET retailers/:slug/contact_groups/import
  def import
  end

  # POST retailers/:slug/contact_groups/bulk_import
  def bulk_import
    notice = 'Debe seleccionar un archivo'

    if import_params['csv_file'].present?
      cg = current_retailer.contact_groups.create(name: params[:name], imported: true)
      results = ContactGroup.csv_import(current_retailer_user, import_params['csv_file'], cg.name, cg.id)

      notice = ['La importación está en proceso. Recibirá un correo cuando haya culminado.']
      notice = results[:body][:errors].flatten if results[:status] != :ok
    end

    redirect_to(
      retailers_contact_groups_path(current_retailer),
      notice: notice
    )
  end

  # GET retailers/:slug/contact_groups/:id/import_update
  def import_update
  end

  # POST retailers/:slug/contact_groups/:id/bulk_update
  def bulk_update
    notice = 'Debe seleccionar un archivo'

    if import_params['csv_file'].present?
      results = ContactGroup.csv_import(current_retailer_user, import_params['csv_file'], @contact_group.name, @contact_group.id)

      notice = ['La importación está en proceso. Recibirá un correo cuando haya culminado.']
      notice = results[:body][:errors].flatten if results[:status] != :ok
    end

    redirect_to(
      retailers_contact_groups_path(current_retailer),
      notice: notice
    )
  end

  # PUT retailers/:slug/contact_groups/:id/archive
  def archive
    @contact_group.archived!

    redirect_to retailers_contact_groups_path(current_retailer)
  end

  # DELETE retailers/:slug/contact_groups/:id
  def destroy
    @contact_group.destroy!

    redirect_to retailers_contact_groups_path(current_retailer)
  end

  private

    def set_contact_group
      @contact_group = current_retailer.contact_groups.find_by(web_id: params[:id]) || not_found
    end

    def check_customers
      return if current_retailer.customers.exists?

      redirect_to(retailers_customers_path(current_retailer), notice: 'Debe registrar clientes primero') && return
    end

    def whatsapp_integrated?
      redirect_to(root_path, notice: 'No estás integrado con WhatsApp') && return unless current_retailer.whatsapp_integrated?
    end

    def contact_group_params
      params.require(:contact_group).permit(
        :name,
        customer_ids: []
      )
    end

    def import_params
      params.permit(:csv_file)
    end
end
