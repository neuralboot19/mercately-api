class CustomerTag < ApplicationRecord
  belongs_to :tag
  belongs_to :customer
end
