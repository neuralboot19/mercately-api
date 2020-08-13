module Whatsapp::Gupshup::V1
  class Outbound::Users < Base
    # User OPT In Phone
    def opt_in(phone)
      url = "#{GUPSHUP_BASE_URL}/app/opt/in/#{@retailer.gupshup_src_name}"

      body = "user=#{phone}"
      response = post(url, body)

      # The opt in response only returns a 202 code if success
      { code: response.code }
    end

    # Fetch Opt-In Users
    def fetch_optin_users
      url = "#{GUPSHUP_BASE_URL}/users/#{@retailer.gupshup_src_name}"

      response = get(url)

      # Returns the Gupshup response
      {
        code: response.code,
        body: JSON.parse(response.read_body)
      }
    end
  end
end
