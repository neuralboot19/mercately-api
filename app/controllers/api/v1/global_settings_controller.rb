class Api::V1::GlobalSettingsController < ApplicationController
  
  # GET /global_setting
  def index
    if params[:setting_key]
      key = GlobalSetting.find_by(setting_key: params[:setting_key])
      if key.present?
        return render json: {key.setting_key => key.value}, status: :ok
      end
    end

    render json: { error: "key not found" }, status: :not_found
  end
end