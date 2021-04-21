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

  scope :submitted, -> { where(submitted: true) }

  enum key: %i[text image video file]
  enum status: %i[pending accepted rejected]

  def submitted!
    update(submitted: true)
  end

  private

    def send_accepted_email
      GsTemplateMailer.accepted(id).deliver_now
    end

    def send_rejected_email
      GsTemplateMailer.rejected(id).deliver_now
    end

    def send_submitted_email
      GsTemplateMailer.submitted(id).deliver_now
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
end
