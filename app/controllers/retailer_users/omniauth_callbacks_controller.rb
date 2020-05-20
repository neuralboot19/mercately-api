class RetailerUsers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include CurrentRetailer
  before_action :authenticate_retailer_user!

  def facebook
    # TODO: validar que el usuario no selecciono mas de una pagina
    auth = request.env['omniauth.auth']
    permissions = Facebook::Api.validate_granted_permissions(auth.credentials.token, session['auth_connection_type'])
    unless permissions[:granted_permissions]
      redirect_to retailers_integrations_path(current_retailer_user.retailer), notice:
        'Debes otorgar todos los permisos solicitados, de lo contrario puede que la aplicación' \
        ' no funcione correctamente.'
      return
    end

    @retailer_user = RetailerUser.from_omniauth(auth, current_retailer_user, permissions[:permissions])

    return if check_facebook_retailer(permissions)
    return if select_catalog(permissions)
    check_persistence
  end

  def failure
    redirect_to root_path
  end

  def messenger
    session['auth_connection_type'] = 'messenger'
    scope = 'email,pages_messaging,manage_pages,pages_show_list'

    redirect_to retailer_user_facebook_omniauth_authorize_path, flash: { scope: scope }
  end

  def catalog
    session['auth_connection_type'] = 'catalog'
    scope = 'business_management,catalog_management'
    scope += ',email,pages_messaging,manage_pages,pages_show_list' if
      current_retailer_user.retailer.facebook_retailer

    redirect_to retailer_user_facebook_omniauth_authorize_path, flash: { scope: scope }
  end

  def setup
    request.env['omniauth.strategy'].options['scope'] = flash[:scope] ||
      request.env['omniauth.strategy'].options['scope']
    head :no_content
  end

  private

    def check_facebook_retailer(permissions)
      if @retailer_user.retailer.facebook_retailer.nil? &&
        permissions[:permissions].any? { |p| p['permission'] == 'manage_pages' && p['status'] == 'granted' }
        redirect_to root_path, notice: 'Ya existe una cuenta de Mercately con esta cuenta de Facebook'
        return true
      end

      false
    end

    def select_catalog(permissions)
      if @retailer_user.retailer.facebook_catalog && @retailer_user.retailer.facebook_catalog.uid.nil? &&
        permissions[:permissions].any? { |p| p['permission'] == 'catalog_management' && p['status'] == 'granted' }
        redirect_to retailers_select_catalog_path(current_retailer_user.retailer)
        return true
      end

      false
    end

    def check_persistence
      if @retailer_user.persisted?
        sign_in_and_redirect @retailer_user, event: :authentication
        set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
      else
        session['devise.facebook_data'] = request.env['omniauth.auth']
        redirect_to new_retailer_user_registration_url
      end
    end
end
