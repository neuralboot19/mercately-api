module Responseable
  extend ActiveSupport::Concern

  def set_response(status, message, data = '{"data":{}}', total_pages = 0)
    response.headers['X-Total-Pages'] = total_pages

    render status: status, json: {
      message: message,
      info: JSON.parse(data)
    }
  end
end
