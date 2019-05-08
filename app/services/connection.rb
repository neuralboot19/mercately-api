class Connection
  def self.prepare_connection(url)
    Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to $stdout
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def self.get_request(connection)
    connection.get
  end

  def self.post_request(connection, body)
    connection.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = body
    end
  end

  def self.post_request(connection, body)
    connection.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = body
    end
  end

  def self.put_request(connection, body)
    connection.put do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Accept'] = 'application/json'
      req.body = body
    end
  end
end
