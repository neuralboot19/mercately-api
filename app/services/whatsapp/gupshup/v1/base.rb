class Whatsapp::Gupshup::V1::Base
  GUPSHUP_API_KEY = ENV['GUPSHUP_API_KEY']
  GUPSHUP_BASE_URL = 'https://api.gupshup.io/sm/api/v1'

  def initialize(retailer=nil, customer=nil)
    @retailer = retailer
    @customer = customer
  end

  def get(url)
    url = URI(url)

    https = Net::HTTP.new(url.host, url.port);
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['apikey'] = GUPSHUP_API_KEY

    https.request(request)
  end

  def post(url, body)
    url = URI(url)

    https = Net::HTTP.new(url.host, url.port);
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['apikey'] = GUPSHUP_API_KEY
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request.body = body

    https.request(request)
  end

  def post_form(url, form_data)
    url = URI(url)

    https = Net::HTTP.new(url.host, url.port);
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['apikey'] = GUPSHUP_API_KEY
    request.set_form form_data, 'multipart/form-data'

    https.request(request)
  end
end
