module Whatsapp::Gupshup::V1
  class Outbound::Users < Base
    # Bulk Upload OPT In Phones
    def upload_list(file)
      url = "#{GUPSHUP_BASE_URL}/users/bulkUpload/#{@retailer.gupshup_src_name}"
      form_data = [['optinList', file]]
      response = post_form(url, form_data)

      # Returns the Gupshup response
      {
        code: response.code,
        body: JSON.parse(response.read_body)
      }
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
