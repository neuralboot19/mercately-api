class GsTemplate < ApplicationRecord
  belongs_to :retailer

  validates_presence_of :label, :key, :category, :text, :example, :language
  validates_length_of :text, maximum: 1024, message: 'Texto de la plantilla muy largo. ' \
    'Máximo 1024 caracteres (sin contar variables)'
  validates :label, uniqueness: { scope: :retailer_id, message: 'Etiqueta ya está en uso' }

  validate :vars_repeated?

  before_create :format_label
  after_create :send_submitted_email, if: :pending?
  after_update :send_accepted_email, if: :accepted?
  after_update :send_rejected_email, if: :rejected?

  enum key: %i[text image video file]
  enum status: %i[pending accepted rejected submitted]

  LANGUAGE_CODES = { spanish: 'es_ES', english: 'en_US' }.freeze

  def submit_template
    return unless retailer.gupshup_app_id.present? && retailer.gupshup_app_token.present?

    headers = {
      'Connection': 'keep-alive',
      'token': retailer.gupshup_app_token
    }

    body = {
      elementName: label,
      languageCode: GsTemplate::LANGUAGE_CODES[language.to_sym],
      category: category,
      templateType: key.upcase,
      content: text,
      example: example,
      vertical: label
    }

    url = "https://partner.gupshup.io/partner/app/#{retailer.gupshup_app_id}/templates"
    conn = Connection.prepare_connection(url)
    response = Connection.post_form_request(conn, body, headers)
    resp_json = JSON.parse(response.body)
    return unless resp_json['template'].present?

    set_response_status(resp_json['template'])
    self.ws_template_id = resp_json['template']['id']
    save
  end

  private

    def send_accepted_email
      RetailerUser.active_admins(retailer.id).each do |ru|
        GsTemplateMailer.accepted(id, ru).deliver_now
      end
    end

    def send_rejected_email
      RetailerUser.active_admins(retailer.id).each do |ru|
        GsTemplateMailer.rejected(id, ru).deliver_now
      end
    end

    def send_submitted_email
      RetailerUser.active_admins(retailer.id).each do |ru|
        GsTemplateMailer.submitted(id, ru).deliver_now
      end
    end

    def format_label
      label.downcase!
      label.gsub!(/ /, '_')
      label.gsub!(/[^a-z0-9_]/, '')
    end

    # Se buscan variables repetidas
    def vars_repeated?
      vars = text.scan(/({{[1-9]+[0-9]*}})/).flatten
      counts = vars.group_by(&:itself).transform_values(&:count)
      return false unless counts.map { |k, v| v > 1 }.any?

      errors.add(:base, 'Hay variables repetidas')
    end

    def set_response_status(data)
      self.status = case data['status']
                    when 'PENDING'
                      'submitted'
                    when 'APPROVED'
                      'accepted'
                    when 'REJECTED'
                      'rejected'
                    end
    end
end
