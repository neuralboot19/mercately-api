module Shared
  class AutomaticAssignments
    def notify_agents(customer, agent, former_agent = nil)
      customer.reload
      retailer = customer.retailer
      agent_customer = customer.agent_customer

      # Se preparan los agentes que van a ser notificados
      data = if former_agent.present?
               agents = [agent, former_agent]
               [retailer, agents, agent_customer, customer]
             else
               [retailer, RetailerUser.active(retailer.id).to_a, agent_customer, customer]
             end

      service = customer.ws_active ? 'whatsapp' : customer.pstype

      # Se envian las notificaciones
      case service
      when 'whatsapp'
        customer.update_attribute(:unread_whatsapp_chat, true)
        gnhm = Whatsapp::Gupshup::V1::Helpers::Messages.new
        gnhm.notify_agent!(*data)
        AgentNotificationHelper.notify_agent(data[2], 'whatsapp')
      when 'messenger', 'instagram'
        data.insert(2, nil)
        data << service if service == 'instagram'
        customer.update_attribute(:unread_messenger_chat, true)
        facebook_helper = FacebookNotificationHelper
        facebook_helper.broadcast_data(*data)
        AgentNotificationHelper.notify_agent(data[3], service)
      end
    end
  end
end
