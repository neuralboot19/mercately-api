module IntegrationHelper
  def ec_auth_url
    "https://auth.mercadolibre.com.ec/authorization?response_type=code&client_id=#{ENV['MERCADO_LIBRE_ID']}"
  end
end
