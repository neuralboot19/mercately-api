ActiveAdmin.register Notification do
  permit_params :title, :body, :visible_for, :visible_until, :published

  controller do
    skip_before_action :verify_authenticity_token
  end

  member_action :upload, method: :post do
    success = resource.files.attach(params[:file_upload])
    result = success ? { link: url_for(resource.files.last) } : {}
    render json: result
  end

  index do
    selectable_column
    id_column
    column :title
    column :published
    column :visible_for
    column :visible_until
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs :title
    f.inputs do
      f.input :visible_for, as: :select, options: Notification.visible_fors.keys, include_blank: false
      f.input :visible_until, as: :datetime_picker, input_html: { min: Time.now }
      unless resource.new_record?
        options = {
          imageUploadParam: 'file_upload',
          imageUploadURL: upload_admin_notification_path(resource.id)
        }
        f.input :body, as: :froala_editor, input_html: { data: { options: options } }
        f.input :published
      end
    end
    f.actions
  end
end
