ActiveAdmin.register GlobalSetting do
  permit_params :setting_key, :value
end
