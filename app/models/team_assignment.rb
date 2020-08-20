class TeamAssignment < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  has_many :agent_teams, dependent: :destroy
  has_many :retailer_users, through: :agent_teams
  has_many :agent_customers

  validates :name, presence: true
  validate :default_activation_unique

  before_destroy :check_destroy_requirements
  after_create :generate_web_id

  scope :active_for_assignments, -> { where(active_assignment: true) }

  accepts_nested_attributes_for :agent_teams, reject_if: :all_blank, allow_destroy: true

  def to_param
    web_id
  end

  private

    def default_activation_unique
      return unless default_assignment == true

      ta_aux = retailer.team_assignments.where(default_assignment: true)
      exist_other = if new_record?
                      ta_aux.exists?
                    else
                      ta_aux.where.not(id: id).exists?
                    end

      errors.add(:base, 'Ya existe un Equipo con la asignación por defecto activa') if exist_other
    end

    def check_destroy_requirements
      return unless agent_customers.present?

      errors.add(:base, 'Equipo no se puede eliminar, posee chats asignados')
      throw(:abort)
    end
end
