class Connection
  def self.prepare_connection(url)
    Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to $stdout
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def self.get_request(connection)
    response = connection.get
    JSON.parse(response.body)
  end
end
