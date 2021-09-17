class GlobalSetting < ApplicationRecord
  validates :setting_key, presence: true, uniqueness: true
  validates :value, presence: true
end
