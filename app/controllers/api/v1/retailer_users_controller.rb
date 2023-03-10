class Api::V1::RetailerUsersController < Api::ApiController
  include CurrentRetailer

  def index
    agents = if params[:search]
               current_retailer.retailer_users.ransack(full_name_cont: params[:search]).result
             else
               current_retailer.retailer_users.limit(20)
             end

    serialized = ActiveModelSerializers::SerializableResource.new(
      agents,
      each_serializer: Retailers::Api::V1::AgentSerializer
    ).as_json

    if agents.present?
      render status: 200, json: { agents: serialized }
    else
      render status: 404, json: { agents: serialized, message: 'Agente no encontrado' }
    end
  end

  def loged_retailer_user
    serialized = Retailers::Api::V1::AgentSerializer.new(current_retailer_user)
    render status: :ok, json: { current_retailer_user: serialized }
  end

  def retailer_users_actives
    agents = RetailerUser.active(current_retailer.id)

    serialized = ActiveModelSerializers::SerializableResource.new(
      agents,
      each_serializer: Retailers::Api::V1::AgentSerializer
    ).as_json

    if agents.present?
      render status: 200, json: { agents: serialized }
    else
      render status: 404, json: { agents: serialized, message: 'Agente no encontrado' }
    end
  end

  def retailer_users_by_role
    agents = if current_retailer_user.admin? || current_retailer_user.supervisor?
                RetailerUser.active(current_retailer.id)
              elsif current_retailer_user.agent?
                [current_retailer_user]
              end

    serialized = ActiveModelSerializers::SerializableResource.new(
      agents,
      each_serializer: Retailers::Api::V1::AgentSerializer
    ).as_json

    if agents.present?
      render status: 200, json: { agents: serialized }
    else
      render status: 404, json: { agents: serialized, message: 'Agente no encontrado' }
    end
  end
end
