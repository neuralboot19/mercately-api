module Whatsapp
  module EndpointsConnection
    def get(url, body, headers)
      url = URI(url)

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request = copy_headers(headers, request)
      request.body = body

      https.request(request)
    end

    def post(url, body, headers)
      url = URI(url)

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["Content-Type"] = "application/x-www-form-urlencoded"
      request = copy_headers(headers, request)
      request.body = body

      https.request(request)
    end

    def post_form(url, form_data, headers)
      url = URI(url)

      https = Net::HTTP.new(url.host, url.port);
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request = copy_headers(headers, request)
      request.set_form form_data, 'multipart/form-data'

      https.request(request)
    end

    def copy_headers(headers, request)
      headers.map do |k, v|
        request[k] = v
      end

      request
    end
  end
end
