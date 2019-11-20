# frozen_string_literal: true

class RetailerUsers::SessionsController < Devise::SessionsController
  before_action :set_locale
  after_action :after_login, only: :create
  after_action :after_logout, only: :destroy

  protected

    def set_locale
      I18n.locale = :es
    end

    def after_login
      cookies[:user_id] = current_retailer_user.id
      retailer = current_retailer_user.retailer
      MercadoLibre::Retailer.new(retailer).update_retailer_info if
        retailer.meli_retailer && retailer.incomplete_meli_profile?
    end

    def after_logout
      cookies[:user_id] = nil
    end
end
