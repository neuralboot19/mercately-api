# frozen_string_literal: true

class RetailerUsers::PasswordsController < Devise::PasswordsController
  before_action :set_locale

  protected

    def set_locale
      I18n.locale = :es
    end
end
