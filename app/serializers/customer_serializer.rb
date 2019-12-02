class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :psid
  has_many :facebook_messages
end
