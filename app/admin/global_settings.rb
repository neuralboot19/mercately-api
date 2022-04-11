ActiveAdmin.register GlobalSetting do
  actions :all, except: :destroy
  permit_params :setting_key, :value
end
