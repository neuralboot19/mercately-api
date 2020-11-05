class CustomerRelatedDatum < ApplicationRecord
  belongs_to :customer
  belongs_to :customer_related_field
end
