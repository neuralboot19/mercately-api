class Retailers::AutomaticAnswersController < RetailersController
  before_action :set_automatic_answer, only: :save_automatic_answer

  def manage_automatic_answers
    platform = guess_platform
    return unless platform

    @message_new_customer = current_retailer.automatic_answers
      .find_or_initialize_by(platform: platform, message_type: :new_customer)
    @message_inactive_customer = current_retailer.automatic_answers
      .find_or_initialize_by(platform: platform, message_type: :inactive_customer)
  end

  def save_automatic_answer
    unless @automatic_answer
      redirect_to retailers_manage_automatic_answers_path(current_retailer, platform:
        automatic_answer_params[:platform]), notice: I18n.t("retailer.settings.automatic_answers.message_not_found")
      return
    end

    if @automatic_answer.update(automatic_answer_params)
      redirect_to retailers_manage_automatic_answers_path(current_retailer, platform:
        automatic_answer_params[:platform]), notice: I18n.t("retailer.settings.automatic_answers.message_saved_successfully")
    else
      redirect_to retailers_manage_automatic_answers_path(current_retailer, platform:
        automatic_answer_params[:platform]), notice: 'Error: ' + I18n.t("retailer.settings.automatic_answers.all_fields_is_required")
    end
  end

  private

    def automatic_answer_params
      params
        .require(:automatic_answer)
        .permit(:message,
                :status,
                :interval,
                :message_type,
                :platform)
    end

    def set_automatic_answer
      platform = guess_platform
      return unless platform

      @automatic_answer = current_retailer.automatic_answers
        .find_or_initialize_by(platform: platform, message_type:
        params[:automatic_answer][:message_type])
    end

    def guess_platform
      platforms = []
      platforms << 'whatsapp' if current_retailer.whatsapp_integrated?
      platforms << 'messenger' if current_retailer.facebook_retailer&.connected?
      platforms << 'instagram' if current_retailer.facebook_retailer&.instagram_integrated

      platform = params[:platform] || params[:automatic_answer][:platform]

      return platform if platform.present? && platforms.include?(platform)
    end
end
