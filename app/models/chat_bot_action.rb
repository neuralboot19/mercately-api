class ChatBotAction < ApplicationRecord
  belongs_to :chat_bot_option
  belongs_to :retailer_user, required: false
  belongs_to :customer_related_field, required: false
  belongs_to :jump_option, class_name: "ChatBotOption", required: false
  has_many :action_tags, dependent: :destroy
  has_many :tags, through: :action_tags

  EXECUTION_ORDER = [0, 1, 5, 6, 8, 7, 2, 9, 3, 4].freeze

  validate :avoid_same_option_to_jump

  before_save :manage_save_on_db_action
  after_create :generate_option

  enum action_type: %i[
    add_tag
    assign_agent
    get_out_bot
    go_back_bot
    go_init_bot
    save_on_db
    exec_callback
    auto_generate_option
    repeat_endpoint_option
    jump_to_option
  ]
  enum classification: %i[default success failed]
  enum action_event: %i[post get put patch remove]
  enum payload_type: %i[json form]

  scope :order_by_action_type, -> do
    order(Arel.sql(EXECUTION_ORDER.map { |action| "action_type=#{action} DESC" }.join(', ')))
  end

  scope :classified, -> (classification) { where(classification: classification) }

  def headers
    read_attribute(:headers).map { |h| Header.new(h) }
  end

  def headers_attributes=(attributes)
    headers = []
    attributes.each do |index, attrs|
      next if '1' == attrs.delete("_destroy")
      headers << attrs
    end

    write_attribute(:headers, headers)
  end

  def data
    read_attribute(:data).map { |d| Data.new(d) }
  end

  def data_attributes=(attributes)
    data = []
    attributes.each do |index, attrs|
      next if '1' == attrs.delete("_destroy")
      data << attrs
    end

    write_attribute(:data, data)
  end

  class Header
    attr_accessor :key, :value

    def initialize(data = {})
      @key = data['key'] || ''
      @value = data['value'] || ''
    end

    def persisted?
      false
    end

    def _destroy
      false
    end
  end

  class Data
    attr_accessor :key, :value

    def initialize(data = {})
      @key = data['key'] || ''
      @value = data['value'] || ''
    end

    def persisted?
      false
    end

    def _destroy
      false
    end
  end

  private

    def generate_option
      return unless action_type == 'auto_generate_option'

      ChatBotOption.create(option_type: :form, parent: chat_bot_option, chat_bot: chat_bot_option.chat_bot)
    end

    def manage_save_on_db_action
      return unless action_type == 'save_on_db'

      related = chat_bot_option.chat_bot.retailer.customer_related_fields.find_by_identifier(target_field)
      self.customer_related_field = related.presence || nil
    end

    def avoid_same_option_to_jump
      return unless action_type == 'jump_to_option'

      errors.add(:jump_option_id, 'La opción origen y la opción destino no pueden ser la misma.') if
        jump_option_id == chat_bot_option_id
    end
end
