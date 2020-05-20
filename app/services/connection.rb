class Connection
  def self.prepare_connection(url)
    Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to $stdout
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def self.get_request(connection)
    get_connection = connection.get
    json_body = get_connection.body

    JSON.parse(json_body)
  end

  def self.post_request(connection, body)
    post_connection = connection.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = body
    end

    post_connection
  end

  def self.post_form_request(connection, body)
    post_connection = connection.post do |req|
      req.body = body
    end

    post_connection
  end

  def self.put_request(connection, body)
    put_connection = connection.put do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Accept'] = 'application/json'
      req.body = body
    end

    put_connection
  end

  def self.delete_request(connection)
    connection.delete
  end
end
