class CustomerBotResponse < ApplicationRecord
  belongs_to :customer
  belongs_to :chat_bot_option

  enum status: %i[success failed]

  def response
    resp = read_attribute(:response)

    if resp.is_a?(Array)
      resp.map { |e| Response.new(e) }
    else
      Response.new(resp)
    end
  end

  class Response
    attr_accessor :option_name, :message, :options

    def initialize(data = {})
      @option_name = data['option_name'] || ''
      @message = data['message'] || ''

      @options = data['options'].map.with_index { |opt, index| Option.new(opt, index + 1) } if data['options'].present?
    end

    def insert_return_options(opt, msg_options)
      size = msg_options.size
      if opt.go_past_option
        size = size + 1

        msg_options << Option.new({
          'key': '_back_',
          'value': 'Volver al paso anterior'
        }.as_json, size)
      end

      if opt.go_start_option
        size = size + 1

        msg_options << Option.new({
          'key': '_start_',
          'value': 'Ir al menú principal'
        }.as_json, size)
      end

      msg_options
    end

    class Option
      attr_accessor :key, :value, :position

      def initialize(data = {}, position = 1)
        @key = data['key'] || ''
        @value = data['value'] || ''
        @position = position
      end
    end
  end
end
