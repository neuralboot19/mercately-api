class AgentNotificationSerializer
  include FastJsonapi::ObjectSerializer
  extend NotificationsHelper
  belongs_to :retailer_user
  belongs_to :customer
  attributes :customer_id, :notification_type, :status, :created_at

  attribute :chat_path do |object|
    case object.notification_type
    when 'whatsapp'
      'whatsapp_chats'
    when 'messenger'
      'facebook_chats'
    when 'instagram'
      'instagram_chats'
    else
      raise StandardError, 'Chat type not valid for notification'
    end
  end

  attribute :chat_type_icon do |object|
    chat_type_icon(object.notification_type)
  end

  attribute :customer_name do |object|
    customer_name(object.customer)
  end
end
