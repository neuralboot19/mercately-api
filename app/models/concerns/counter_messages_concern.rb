module CounterMessagesConcern
  extend ActiveSupport::Concern

  included do
    after_commit :set_counter, on: :create
  end

  private

    def set_counter
      return unless direction == 'inbound'

      customer.update_column(:count_unread_messages, customer.count_unread_messages + 1)

      admins_supervisors = retailer.admins.or(retailer.supervisors)
      admins_supervisors.update_all(whatsapp_unread: true)

      agent = customer.agent
      return if agent && !agent.agent?

      if agent.present?
        agent.update_column(:whatsapp_unread, true)
      else
        retailer.retailer_users.active_agents.where(only_assigned: false).update_all(whatsapp_unread: true)
      end
    end
end
