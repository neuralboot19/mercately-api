# frozen_string_literal: true

class RetailerUsers::PasswordsController < Devise::PasswordsController
  before_action :set_locale

  # POST /resource/password
  def create
    super do |resource|
      flash[:message] = 'Se han enviado las instrucciones al email proporcionado' if
        successfully_sent?(resource)
    end
  end

  protected

    def set_locale
      I18n.locale = :es
    end
end
