class AutomaticAnswer < ApplicationRecord
  belongs_to :retailer
  has_many :automatic_answer_days

  validates_presence_of :retailer, :message, :message_type
  validate :validate_schedule, on: [:create, :update]
  validate :enabled_platform, on: [:create, :update]

  enum message_type: %i[new_customer inactive_customer all_customer]

  accepts_nested_attributes_for :automatic_answer_days, reject_if: :all_blank, allow_destroy: true

  attr_accessor :days

  private

    def validate_schedule
      if always_active && any_other_exists?
        errors.add(:base, 'Existen mensajes configurados que interfieren con el que intenta guardar.')
        return
      end

      if always_active_exists?
        errors.add(:base, 'Existe al menos un mensaje siempre activo que interfiere con el que intenta guardar.')
        return
      end

      if cross_schedule?
        errors.add(:base, 'Existen mensajes configurados que interfieren con el que intenta guardar.')
        return
      end
    end

    def always_active_exists?
      str_sql = 'retailer_id = ? AND message_type IN (?) AND always_active = true'
      str_sql += query_platforms

      if id
        str_sql += ' AND id <> ?'
        AutomaticAnswer.where(str_sql, retailer_id, query_message_types, id).exists?
      else
        AutomaticAnswer.where(str_sql, retailer_id, query_message_types).exists?
      end
    end

    def any_other_exists?
      str_sql = 'retailer_id = ? AND message_type IN (?)'
      str_sql += query_platforms

      if id
        str_sql += ' AND automatic_answers.id <> ?'
        AutomaticAnswer.joins(:automatic_answer_days)
          .where(str_sql, retailer_id, query_message_types, id).exists?
      else
        AutomaticAnswer.joins(:automatic_answer_days)
          .where(str_sql, retailer_id, query_message_types).exists?
      end
    end

    def cross_schedule?
      str_sql = 'retailer_id = ? AND message_type IN (?)'
      str_sql += query_platforms

      messages_ids = if id
                       str_sql += ' AND id <> ?'
                       AutomaticAnswer.where(str_sql, retailer_id, query_message_types, id).ids
                     else
                       AutomaticAnswer.where(str_sql, retailer_id, query_message_types).ids
                     end

      return unless days.present? && messages_ids.present?

      service = AutomaticAnswers::AutomaticAnswerDayQuery.new
      days.each do |answer_day|
        next if answer_day['_destroy']

      invalid = if answer_day['all_day']
                  service.invalid_all_day?(messages_ids, answer_day['day'])
                else
                  service.invalid_schedule?(messages_ids, answer_day)
                end

        return true if invalid
      end

      false
    end

    def query_platforms
      platforms = []
      platforms << 'whatsapp = TRUE' if whatsapp
      platforms << 'messenger = TRUE' if messenger
      platforms << 'instagram = TRUE' if instagram

      return '' if platforms.blank?

      " AND (#{platforms.join(' OR ')})"
    end

    def query_message_types
      types = [2]
      types << 0 if message_type.in?(['new_customer', 'all_customer'])
      types << 1 if message_type.in?(['inactive_customer', 'all_customer'])

      types
    end

    def enabled_platform
      if whatsapp && !retailer.whatsapp_integrated?
        errors.add(:base, 'No puede crear mensajes para WhatsApp.')
        return
      end

      if messenger && !retailer.facebook_integrated?
        errors.add(:base, 'No puede crear mensajes para Messenger.')
        return
      end

      if instagram && !retailer.instagram_integrated?
        errors.add(:base, 'No puede crear mensajes para Instagram.')
        return
      end
    end
end
