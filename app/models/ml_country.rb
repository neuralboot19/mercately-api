class MlCountry < ApplicationRecord
  validates_presence_of :name, :site, :domain
end
