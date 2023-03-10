class Connection
  def self.prepare_connection(url, request = :url_encoded)
    Faraday.new(url: url) do |faraday|
      faraday.request  request             # form-encode POST params
      faraday.response :logger                  # log requests to $stdout
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def self.get_request(connection, headers = {})
    get_connection = connection.get do |req|
      if headers.present?
        headers.each do |k, v|
          req.headers[k] = v
        end
      end
    end
    json_body = get_connection.body

    JSON.parse(json_body)
  end

  def self.post_request(connection, body, headers = {})
    post_connection = connection.post do |req|
      req.headers['Content-Type'] = 'application/json'
      if headers.present?
        headers.each do |k, v|
          req.headers[k] = v
        end
      end
      req.body = body
    end

    post_connection
  end

  def self.post_form_request(connection, body, headers = {})
    post_connection = connection.post do |req|
      if headers.present?
        headers.each do |k, v|
          req.headers[k] = v
        end
      end
      req.body = body
    end

    post_connection
  end

  def self.put_request(connection, body, headers = {})
    put_connection = connection.put do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Accept'] = 'application/json'

      if headers.present?
        headers.each do |k, v|
          req.headers[k] = v
        end
      end

      req.body = body
    end

    put_connection
  end

  def self.patch_request(connection, body, headers = {})
    put_connection = connection.patch do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Accept'] = 'application/json'
      if headers.present?
        headers.each do |k, v|
          req.headers[k] = v
        end
      end
      req.body = body
    end

    put_connection
  end

  def self.delete_request(connection)
    connection.delete
  end
end
