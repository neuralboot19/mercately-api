ActiveAdmin.register GsTemplate do
  actions :all, except: [:new, :create, :update, :destroy]
  permit_params :status, :label, :key, :category, :text, :example, :language, :reason

  scope :pending, default: true
  scope :accepted
  scope :rejected
  scope :submitted

  filter :retailer, as: :searchable_select

  batch_action :submit do |ids|
    batch_action_collection.where(id: ids).pending.find_each(&:submit_template)

    redirect_to admin_gs_templates_path, alert: 'Templates submitted!'
  end

  batch_action :accept do |ids|
    batch_action_collection.where(id: ids).pending.find_each(&:accepted!)
    redirect_to admin_gs_templates_path, alert: 'Templates accepted!'
  end

  batch_action :reject do |ids|
    batch_action_collection.where(id: ids).pending.find_each(&:rejected!)
    redirect_to admin_gs_templates_path, alert: 'Templates rejected!'
  end

  index do
    selectable_column
    id_column
    column :status
    column :label
    column :category
    column :text
    column :example
    column :language
    column :retailer
    column :ws_template_id
    column :created_at
    column :updated_at

    actions
  end

  form do |f|
    f.inputs :status, :label, :key, :category, :text, :example, :language
  end
end
