# frozen_string_literal: true

class RetailerUsers::SessionsController < Devise::SessionsController
  before_action :set_locale
  after_action :after_login, only: :create


  protected

    def set_locale
      I18n.locale = :es
    end

    def after_login
      retailer = current_retailer_user.retailer
      MercadoLibre::Retailer.new(retailer).update_retailer_info if
        retailer.meli_retailer && retailer.incomplete_meli_profile?
    end
end
