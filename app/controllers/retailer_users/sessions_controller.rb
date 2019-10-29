# frozen_string_literal: true

class RetailerUsers::SessionsController < Devise::SessionsController
  before_action :set_locale

  protected

    def set_locale
      I18n.locale = :es
    end

    def after_sign_in_path_for(_resource)
      retailer = current_retailer_user.retailer
      MercadoLibre::Retailer.new(retailer).update_retailer_info if
        retailer.meli_retailer && retailer.incomplete_meli_profile?

      super
    end
end
