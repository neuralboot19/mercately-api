class TeamAssignment < ApplicationRecord
  include WebIdGenerateableConcern

  belongs_to :retailer
  has_many :agent_teams, dependent: :destroy
  has_many :retailer_users, through: :agent_teams
  has_many :agent_customers
  has_many :chat_bot_actions

  validates :name, presence: true
  validate :default_activation_unique
  validate :inactive_action, on: :update

  before_destroy :check_destroy_requirements
  after_create :generate_web_id

  scope :active_for_assignments, -> { where(active_assignment: true) }

  accepts_nested_attributes_for :agent_teams, reject_if: :all_blank, allow_destroy: true

  def to_param
    web_id
  end

  def assign_agent(customer)
    with_lock do
      return unless active_assignment

      agent_customer = AgentCustomer.find_by(customer: customer)
      agents = agent_teams.active_ones.order(id: :asc)
      unless agents.present?
        agent_customer&.destroy
        notification_service.notify_agents(customer, nil)
        return
      end

      agent_ids = agents.ids
      pos = agent_ids.index { |a| a > last_assigned.to_i }
      agent_team = agents[pos.to_i]

      if agent_customer.blank?
        return unless AgentCustomer.create(retailer_user_id: agent_team.retailer_user_id, team_assignment_id: id,
          customer_id: customer.id)

        agent_team.update(assigned_amount: agent_team.assigned_amount + 1)
        update_column(:last_assigned, agent_team.id)
        notification_service.notify_agents(customer, agent_team.retailer_user)
      elsif !agent_customer.retailer_user.active || agent_customer.team_assignment_id != agent_team.team_assignment_id
        former_agent = agent_customer.retailer_user
        return unless agent_customer.update(retailer_user_id: agent_team.retailer_user_id, team_assignment_id: id)

        agent_team.update(assigned_amount: agent_team.assigned_amount + 1)
        update_column(:last_assigned, agent_team.id)
        notification_service.notify_agents(customer, agent_team.retailer_user, former_agent)
      end
    end
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

    def inactive_action
      return unless active_assignment == false

      errors.add(:base, 'No puede desactivar el Equipo, posee acciones de ChatBot asociadas') if chat_bot_actions.exists?
    end

    def check_destroy_requirements
      valid = true

      if agent_customers.exists?
        errors.add(:base, 'Equipo no se puede eliminar, posee chats asignados')
        valid = false
      end

      if chat_bot_actions.exists?
        errors.add(:base, 'Equipo no se puede eliminar, posee acciones de ChatBot asociadas')
        valid = false
      end

      throw(:abort) unless valid
    end

    def notification_service
      Shared::AutomaticAssignments.new
    end
end
