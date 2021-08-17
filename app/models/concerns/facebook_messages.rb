module FacebookMessages
  extend ActiveSupport::Concern

  included do
    include AgentMessengerAssignmentConcern
    include MessengerChatBotActionConcern
    belongs_to :facebook_retailer
    belongs_to :customer
    belongs_to :retailer_user, required: false

    validates_uniqueness_of :mid, allow_blank: true

    before_create :set_sender_information
    after_create :sent_by_retailer?
    after_create :assign_agent
    after_commit :send_welcome_message, on: :create, if: -> (obj) { obj.customer.messenger? }
    after_commit :send_inactive_message, on: :create, if: -> (obj) { obj.customer.messenger? }
    after_commit :send_facebook_message, on: :create
    after_commit :broadcast_to_counter_channel, on: [:create, :update]
    after_commit :set_last_interaction, on: :create

    scope :customer_unread, -> { where(date_read: nil, sent_by_retailer: false) }
    scope :retailer_unread, -> { where(date_read: nil, sent_by_retailer: true) }
    scope :inbound, -> { where(sent_by_retailer: false) }
    scope :unread, -> { where(date_read: nil) }
    scope :range_between, -> (start_date, end_date) { where(created_at: start_date..end_date) }

    delegate :retailer, to: :facebook_retailer

    attr_accessor :file_url, :file_content_type
  end

  private

    def platform
      self.class == FacebookMessage ? 'messenger' : 'instagram'
    end

    def sent_by_retailer?
      if sender_uid == facebook_retailer.uid || sender_uid == facebook_retailer.instagram_uid
        update_column(:sent_by_retailer, true)
      end
    end

    def send_facebook_message
      return unless sent_from_mercately

      m = if text.present?
            facebook_service.send_message(id_client, text)
          elsif file_data.present? || file_url.present?
            facebook_service.send_attachment(id_client, file_data, filename, file_url, file_type, file_content_type)
          end
      update_column(:mid, m['message_id'])
      import_facebook_message(m['message_id']) if file_data.present? || file_url.present?
    end

    def broadcast_to_counter_channel
      facebook_helper = FacebookNotificationHelper
      retailer = facebook_retailer.retailer
      agents = customer.agent.present? ? [customer.agent] : retailer.retailer_users.all_customers.to_a
      facebook_helper.broadcast_data(retailer, agents, self, customer.agent_customer, nil, platform)
    end

    def send_welcome_message
      retailer = facebook_retailer.retailer
      welcome_message = retailer.messenger_welcome_message
      total_messages = customer.total_messenger_messages
      return unless total_messages == 1 && welcome_message && sent_by_retailer == false

      send_messenger_notification(welcome_message.message)
    end

    def send_inactive_message
      retailer = facebook_retailer.retailer
      inactive_message = retailer.messenger_inactive_message
      before_last_message_msn = customer.before_last_messenger_message

      return unless inactive_message && sent_by_retailer == false && before_last_message_msn &&
        send_message?(before_last_message_msn, inactive_message)

      send_messenger_notification(inactive_message.message)
    end

    def send_messenger_notification(message)
      self.class.create(
        customer: customer,
        sender_uid: facebook_retailer.uid,
        id_client: id_client,
        facebook_retailer: facebook_retailer,
        text: message,
        sent_from_mercately: true,
        sent_by_retailer: true,
        url: nil,
        file_type: nil,
        filename: nil
      )
    end

    def send_message?(before_last_message_msn, inactive_message)
      hours = ((created_at - before_last_message_msn.created_at) / 3600).to_i

      hours >= inactive_message.interval
    end

    def import_facebook_message(mid)
      facebook_service.import_delivered(mid, customer.psid)
    end

    def facebook_service
      Facebook::Messages.new(facebook_retailer, platform)
    end

    def set_last_interaction
      customer.update_column(:last_chat_interaction, created_at)
    end

    def set_sender_information
      return unless retailer_user.present?

      self.sender_first_name = retailer_user.first_name
      self.sender_last_name = retailer_user.last_name
      self.sender_email = retailer_user.email
    end
end
