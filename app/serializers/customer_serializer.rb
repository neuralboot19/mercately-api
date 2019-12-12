class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :psid, :email, :phone, :address, :city, :state, :zip_code, :id_number
end
