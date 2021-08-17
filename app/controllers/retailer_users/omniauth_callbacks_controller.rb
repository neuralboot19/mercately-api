class RetailerUsers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include CurrentRetailer
  before_action :authenticate_retailer_user!

  def facebook
    # TODO: validar que el usuario no selecciono mas de una pagina
    auth = request.env['omniauth.auth']
    auth_connection_type = session['auth_connection_type']
    permissions = Facebook::Api.validate_granted_permissions(auth.credentials.token, auth_connection_type)
    unless permissions[:granted_permissions]
      redirect_to retailers_integrations_path(current_retailer_user.retailer), notice:
        'Debes otorgar todos los permisos solicitados, de lo contrario puede que la aplicación' \
        ' no funcione correctamente.'
      return
    end

    begin
      @retailer_user = RetailerUser.from_omniauth(auth, current_retailer_user, permissions[:permissions],
                                                  auth_connection_type)
    rescue => e
      facebook_retailer = FacebookRetailer.find_by(retailer_id: current_retailer.id)
      facebook_retailer&.update(instagram_integrated: false)
      message = if e == 'NotIgAllowed'
                  'Tu cuenta de Instagram no cumple con los requisitos para la integración'
                else
                  'Ya existe una cuenta de Mercately conectada con esa cuenta de Instagram'
                end
      redirect_to root_path, notice: message
      return
    end

    return if check_facebook_retailer(permissions, auth_connection_type)
    return if check_instagram(permissions, auth_connection_type)
    return if select_catalog(permissions, auth_connection_type)

    check_persistence
  end

  def failure
    redirect_to root_path
  end

  def messenger
    session['auth_connection_type'] = 'messenger'
    scope = 'email,pages_messaging,pages_manage_metadata,pages_read_engagement,pages_show_list'
    if current_retailer_user.retailer.facebook_retailer&.instagram_integrated
      scope += ',instagram_basic,instagram_manage_messages,pages_manage_metadata'
    end

    redirect_to retailer_user_facebook_omniauth_authorize_path, flash: { scope: scope }
  end

  def instagram
    session['auth_connection_type'] = 'instagram'
    scope = 'instagram_basic,instagram_manage_messages,pages_manage_metadata,pages_show_list'
    if current_retailer_user.retailer.facebook_retailer&.connected?
      scope += ',email,pages_messaging,pages_manage_metadata,pages_read_engagement,pages_show_list'
    end

    redirect_to retailer_user_facebook_omniauth_authorize_path, flash: { scope: scope }
  end

  def catalog
    session['auth_connection_type'] = 'catalog'
    scope = 'business_management,catalog_management'
    if current_retailer_user.retailer.facebook_retailer&.connected?
      scope += ',email,pages_messaging,pages_manage_metadata,pages_read_engagement,pages_show_list'
    end
    if current_retailer_user.retailer.facebook_retailer&.instagram_integrated
      scope += ',instagram_basic,instagram_manage_messages,pages_manage_metadata'
    end

    redirect_to retailer_user_facebook_omniauth_authorize_path, flash: { scope: scope }
  end

  def setup
    request.env['omniauth.strategy'].options['scope'] = flash[:scope] || request.env['omniauth.strategy']
      .options['scope']
    head :no_content
  end

  private

    def check_facebook_retailer(permissions, connection_type)
      if @retailer_user.retailer.facebook_retailer.nil? &&
         permissions[:permissions].any? { |p| p['permission'] == 'pages_manage_metadata' &&
          p['status'] == 'granted' } && connection_type == 'messenger'
        redirect_to root_path, notice: 'Ya existe una cuenta de Mercately con esta cuenta de Facebook'
        return true
      end

      false
    end

    def check_instagram(permissions, connection_type)
      if check_instagram_requirements
        redirect_to root_path, notice: 'Tu cuenta de Instagram no cumple con los requisitos para la integración'
        return true
      elsif @retailer_user.retailer.facebook_retailer.nil? &&
         permissions[:permissions].any? { |p| p['permission'] == 'instagram_manage_messages' &&
          p['status'] == 'granted' } && connection_type == 'instagram'
        redirect_to root_path, notice: 'Ya existe una cuenta de Mercately con esta cuenta de Instagram'
        return true
      end

      false
    end

    def check_instagram_requirements
      facebook_service = Facebook::Api.new(@retailer_user.retailer.facebook_retailer, @retailer_user)
      facebook_service.check_instagram_access
    end

    def select_catalog(permissions, connection_type)
      if @retailer_user.retailer.facebook_catalog && @retailer_user.retailer.facebook_catalog.uid.nil? &&
         permissions[:permissions].any? { |p| p['permission'] == 'catalog_management' && p['status'] == 'granted' } &&
         connection_type == 'catalog'
        redirect_to retailers_select_catalog_path(current_retailer_user.retailer)
        return true
      end

      false
    end

    def check_persistence
      if @retailer_user.persisted?
        sign_in_and_redirect @retailer_user, event: :authentication
        kind = session['auth_connection_type'] == 'instagram' ? 'Instagram' : 'Facebook'
        set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
      else
        session['devise.facebook_data'] = request.env['omniauth.auth']
        redirect_to new_retailer_user_registration_url
      end
    end
end
