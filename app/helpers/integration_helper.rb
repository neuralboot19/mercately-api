module IntegrationHelper
  def ml_auth_url(retailer)
    "https://auth.mercadolibre.#{retailer.ml_domain}/authorization?response_type=code&client_id=#{ENV['MERCADO_LIBRE_ID']}"
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
