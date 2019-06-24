# frozen_string_literal: true

class RetailerUsers::SessionsController < Devise::SessionsController
  before_action :set_locale

  protected

    def set_locale
      I18n.locale = :es
    end
end
