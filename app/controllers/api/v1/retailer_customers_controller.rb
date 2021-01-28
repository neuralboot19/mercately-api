class Api::V1::RetailerCustomersController < ApplicationController
  include CurrentRetailer

  def index
    customers = current_retailer.customers.where('email ILIKE :search OR first_name ILIKE :search OR
                                                 last_name ILIKE :search OR phone ILIKE :search OR
                                                 id_number ILIKE :search',
      search: "%#{params[:search]}%").page(params[:page]).per(25)

    serialized = ActiveModelSerializers::SerializableResource.new(customers, each_serializer: CustomerSerializer)

    if customers.present?
      render status: 200, json: { customers: serialized, total_pages: customers.total_pages }
    else
      render status: 404, json: { customers: serialized, total_pages: customers.total_pages, message:
        'Cliente no encontrado' }
    end
  end
end
