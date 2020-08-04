module PaymentezConcern
  extend ActiveSupport::Concern

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def authorize
      unix_timestamp = Time.now.to_i.to_s
      paymentez_server_application_code = ENV['PAYMENTEZ_CODE_SERVER']
      paymentez_server_app_key = ENV['PAYMENTEZ_SECRET_SERVER']
      uniq_token_string = paymentez_server_app_key + unix_timestamp
      uniq_token_hash = Digest::SHA256.hexdigest(uniq_token_string)
      auth_token = paymentez_server_application_code + ';' + unix_timestamp + ';' +  uniq_token_hash
      Base64.encode64(auth_token).gsub("\n", "")
    end

    def do_request(method, body, url)
      connection = Faraday.new
      connection.send(method) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Auth-Token'] = self.authorize
        req.url ENV['PAYMENTEZ_URL'] + url
        req.body = body
      end
    end
  end
end
