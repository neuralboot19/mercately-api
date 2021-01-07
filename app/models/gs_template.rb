class GsTemplate < ApplicationRecord
  belongs_to :retailer

  validates_presence_of :label, :key, :category, :text, :example, :language
  validates_length_of :text, maximum: 1024, too_long: 'Máximo 1024 caracteres (sin contar variables)',
    if: -> (obj) { obj.label.gsub(/{{\d}}/, '').length > 1024 }
  validate :vars_repeated?
  validate :example_match?

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

    def example_match?
      return true if text.gsub(/{{\d}}/, '') == example.gsub(/\[.*?\]/, '')

      errors.add(:base, 'El texto y el ejemplo no coinciden')
    end

    def format_label
      label.downcase!
      label.gsub!(/ /, '_')
      label.gsub!(/[^a-z0-9_]/, '')
    end

    def vars_repeated?
      repeated = false
      (1..100).each do |n|
        # Si no hay mas variables por revisar, salimos del metodo
        return if text.scan(/\{\{#{n}\}\}/).length.zero?
        # Si hay mas de una variable con el mismo identificador se rompe el bucle
        repeated = true if text.scan(/\{\{#{n}\}\}/).length > 1
        break if repeated
      end

      # Y se a;ade el error
      errors.add(:base, 'Hay variables repetidas') if repeated
    end
end
