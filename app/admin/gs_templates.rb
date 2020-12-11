ActiveAdmin.register GsTemplate do
  actions :all, except: [:new, :create, :update, :destroy]
  permit_params :status, :label, :key, :category, :text, :example, :language, :reason

  scope :pending, default: true
  scope :accepted
  scope :rejected

  filter :retailer, as: :searchable_select

  batch_action :accept do |ids|
    batch_action_collection.where(id: ids).pending.find_each(&:accepted!)
    redirect_to admin_gs_templates_path, alert: 'Templates accepted!'
  end

  batch_action :reject do |ids|
    batch_action_collection.where(id: ids).pending.find_each(&:rejected!)
    redirect_to admin_gs_templates_path, alert: 'Templates rejected!'
  end

  form do |f|
    f.inputs :status, :label, :key, :category, :text, :example, :language
  end
end
