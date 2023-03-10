class GsTemplate < ApplicationRecord
  belongs_to :retailer

  validates_presence_of :label, :key, :category, :text, :example, :language
  validates_length_of :text, maximum: 1024, message: 'Texto de la plantilla muy largo. ' \
    'Máximo 1024 caracteres (sin contar variables)'
  validates :label, uniqueness: { scope: :retailer_id, message: 'Etiqueta ya está en uso' }

  validate :vars_repeated?

  after_commit :submit_template, on: :create, if: :pending?
  before_create :format_label
  after_update :send_accepted_email, if: :accepted?
  after_update :send_rejected_email, if: :rejected?

  enum key: %i[text image video document location]
  enum status: %i[pending accepted rejected submitted]

  attr_accessor :file

  LANGUAGE_CODES = { spanish: 'es_ES', english: 'en_US' }.freeze

  def submit_template
    return if ws_template_id || status != 'pending'

    send_submitted_email if api_service.submit_gs_template(self)
  end

  def accept_template
    return unless status == 'submitted'

    api_service.accept_gs_template(self)
  end

  def send_slack_notify(err)
    slack_client.ping(
      [
        'Hola equipo de Marketing',
        "La plantilla de WhatsApp con etiqueta: #{label}, que pertenece al retailer: #{retailer.name}, no fue enviada a Gupshup para su validación",
        "Error: #{err}"
      ].join("\n"))
  rescue StandardError => e
    Raven.capture_exception(e)
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

    def api_service
      @api_service ||= GsTemplates::Api.new
    end

    def slack_client
      Slack::Notifier.new ENV['SLACK_GS_TEMPLATES'], channel: '#gs-templates'
    end
end
