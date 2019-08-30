module IntegrationHelper
  def ec_auth_url
    "https://auth.mercadolibre.com.ec/authorization?response_type=code&client_id=#{ENV['MERCADO_LIBRE_ID']}"
  end

  def humanize_ml_condition(condition)
    case condition
    when 'new_product'
      'Nuevo'
    when 'used'
      'Usado'
    when 'not_specified'
      'No especificado'
    end
  end
end
