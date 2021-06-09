class Api::V1::CustomersController < Api::ApiController
  # TODO: RENAME TO FACEBOOKCHATSCONTROLLER
  include CurrentRetailer
  include ActionView::Helpers::TextHelper
  before_action :sanitize_params, only: [:update]
  before_action :set_customer, except: [:index, :set_message_as_read, :fast_answers_for_messenger, :search_customers]

  def index
    customers = if current_retailer_user.admin? || current_retailer_user.supervisor?
                  current_retailer.customers.facebook_customers.active
                elsif current_retailer_user.agent?
                  current_retailer_user.customers.facebook_customers.active
                end

    @customers = customer_list(customers)
    @customers = @customers&.offset(false)&.offset(params[:offset])
    total_pages = @customers&.total_pages

    render status: 200, json: {
      customers: @customers.present? ? @customers.as_json(methods:
        [
          :unread_message?,
          :last_messenger_message,
          :assigned_agent,
          :tags,
          :unread_messenger_messages
        ]
      ) : [],
      agents: agents,
      agent_list: current_retailer.team_agents,
      storage_id: current_retailer_user.storage_id,
      filter_tags: current_retailer.tags,
      total_customers: total_pages
    }
  end

  def show
    render status: 200, json: {
      customer: @customer.as_json(methods: [:emoji_flag, :tags, :assigned_agent]),
      hubspot_integrated: @customer.retailer.hubspot_integrated?,
      reminders: @customer.reminders.order(created_at: :desc),
      tags: current_retailer.available_customer_tags(@customer.id)
    }
  end

  def update
    if @customer.update(customer_params)
      render status: 200, json: { customer: @customer.as_json(methods: [:emoji_flag, :tags, :assigned_agent]), tags:
        current_retailer.available_customer_tags(@customer.id) }
    else
      render status: 400, json: { customer: @customer.as_json(methods: [:emoji_flag, :tags, :assigned_agent]), errors:
        @customer.errors, tags: current_retailer.available_customer_tags(@customer.id) }
    end
  end

  def messages
    facebook_helper = FacebookNotificationHelper
    @messages = @customer.facebook_messages
    @messages.customer_unread.update_all(date_read: Time.now)
    @messages = @messages.order(created_at: :desc).page(params[:page])
    @customer.update_attribute(:unread_messenger_chat, false)
    facebook_service.send_read_action(@customer.psid, 'mark_seen')
    agents = @customer.agent.present? ? [@customer.agent] : current_retailer.retailer_users.all_customers.to_a

    facebook_helper.broadcast_data(
      current_retailer,
      agents,
      nil,
      @customer.agent_customer,
      @customer
    )
    render status: 200, json: {
      messages: serialize_facebook_messages.to_a.reverse,
      agents: agents,
      storage_id: current_retailer_user.storage_id,
      agent_list: current_retailer.team_agents,
      total_pages: @messages.total_pages,
      customer_id: @customer.id,
      recent_inbound_message_date: @customer.recent_facebook_message_date,
      filter_tags: current_retailer.tags
    }
  end

  def create_message
    message = FacebookMessage.new(
      customer: @customer,
      sender_uid: current_retailer_user.uid,
      id_client: @customer.psid,
      facebook_retailer: current_retailer.facebook_retailer,
      text: params[:message],
      sent_from_mercately: true,
      sent_by_retailer: true,
      retailer_user: current_retailer_user,
      file_type: params[:type]
    )

    render status: 200, json: { message: message } if message.save
  end

  def send_img
    if params[:file_data].present?
      file_data = params[:file_data].tempfile.path
      filename = File.basename(params[:file_data].original_filename)
    end

    message = FacebookMessage.new(
      customer: @customer,
      sender_uid: current_retailer_user.uid,
      id_client: @customer.psid,
      facebook_retailer: current_retailer.facebook_retailer,
      file_data: file_data,
      sent_from_mercately: true,
      sent_by_retailer: true,
      filename: filename,
      retailer_user: current_retailer_user,
      file_url: params[:url],
      file_type: params[:type]
    )

    render status: 200, json: { message: message } if message.save
  end

  def set_message_as_read
    facebook_helper = FacebookNotificationHelper
    @message = FacebookMessage.find(params[:id])
    @message.update_column(:date_read, Time.now)
    facebook_service.send_read_action(@message.customer.psid, 'mark_seen')
    agents = @message.customer.agent ? [@message.customer.agent] : current_retailer.retailer_users.all_customers.to_a

    facebook_helper.broadcast_data(current_retailer, agents, nil, @message.customer.agent_customer, @message.customer)
    render status: 200, json: { message: @message }
  end

  # Filtra las plantillas para messenger por titulo o respuesta
  def fast_answers_for_messenger
    templates = current_retailer.templates.for_messenger.owned_and_filtered(params[:search], current_retailer_user.id)
      .page(params[:page])

    serialized = Api::V1::TemplateSerializer.new(templates)
    render status: 200, json: { templates: serialized, total_pages: templates.total_pages }
  end

  def accept_opt_in
    @customer.send_for_opt_in = true
    return render status: 200, json: { customer_id: @customer.id} if @customer.accept_opt_in!

    render status: 400, json: { error: 'Error al aceptar opt-in de este cliente, intente nuevamente' }
  end

  def selectable_tags
    tags = current_retailer.available_customer_tags(params[:id]) || []
    render status: 200, json: { tags: tags }
  end

  def add_customer_tag
    @customer.customer_tags.create(tag_id: params[:tag_id])
    send_notification(params[:chat_service])

    render status: 200, json: { customer: @customer.as_json(methods: [:emoji_flag, :tags]), tags:
      current_retailer.available_customer_tags(@customer.id) }
  end

  def remove_customer_tag
    @customer.customer_tags.find_by_tag_id(params[:tag_id])&.destroy
    send_notification(params[:chat_service])

    render status: 200, json: { customer: @customer.as_json(methods: [:emoji_flag, :tags]), tags:
      current_retailer.available_customer_tags(@customer.id) }
  end

  def add_tag
    tag = @customer.retailer.tags.create(tag: params[:tag])
    @customer.customer_tags.create(tag_id: tag.id) if tag.present?
    send_notification(params[:chat_service])

    render status: 200, json: { customer: @customer.as_json(methods: [:emoji_flag, :tags]), tags:
      current_retailer.available_customer_tags(@customer.id), filter_tags: current_retailer.tags }
  end

  def toggle_chat_bot
    if @customer.active_bot
      @customer.deactivate_chat_bot!
    else
      @customer.activate_chat_bot!
    end
    send_notification(params[:chat_service])

    render status: 200, json: { customer: @customer }
  end

  def send_bulk_files
    facebook_service.send_bulk_files(@customer, current_retailer_user, params)

    render status: 200, json: { message: 'Mensaje enviado' }
  end

  def search_customers
    customers = current_retailer.customers

    if params[:text].blank?
      customers = customers.limit(300)
    else
      customers = customers.where("CONCAT(lower(first_name), lower(last_name)) ilike ?
        OR email ILIKE ? OR phone ILIKE ?",
        "%#{params[:text].downcase.delete(' ')}%",
        "%#{params[:text].downcase}%",
        "%#{params[:text].downcase}%"
      )
    end
    render json: { customers: customers }
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:customer_id] || params[:id])
    end

    def sanitize_params
      params[:customer].each_pair do |param|
        if params[:customer][param.first]
          next if param.first == 'notes' # Don't remove \n
          next if params[:customer][param.first].in? [true, false]
          params[:customer][param.first] = strip_tags(params[:customer][param.first]).squish
        end
      end
    end

    def facebook_service
      @facebook_service ||= Facebook::Messages.new(current_retailer.facebook_retailer)
    end

    def customer_list(customers)
      return nil unless customers.present?

      customers = customers.select('customers.*, customers.last_chat_interaction as recent_message_date')

      if params[:type].present?
        customers = if ['no_read', 'read'].include?(params[:type])
                      customers.joins(:facebook_messages).where(
                        "facebook_messages.date_read IS
                        #{params[:type] == 'read' ? 'NOT ' : ''}NULL
                        OR customers.unread_messenger_chat = true"
                      )
                    else
                      customers
                    end
      end

      if params[:agent].present?
        case params[:agent]
        when 'all'
          customers
        when 'not_assigned'
          customers = customers.joins("LEFT JOIN agent_customers agc ON agc.customer_id = customers.id")
            .where("agc.retailer_user_id is NULL AND customers.retailer_id = ?", current_retailer.id)
        else
          customer_ids = AgentCustomer.where(retailer_user_id: params[:agent]).select(:customer_id)
          customers = customers.where('customers.id IN (?)', customer_ids)
        end
      end

      if params[:tag].present?
        case params[:tag]
        when 'all'
          customers
        else
          customer_ids = CustomerTag.where(tag_id: params[:tag]).select(:customer_id)
          customers = customers.where('customers.id IN (?)', customer_ids)
        end
      end

      customers = customers.by_search_text(params[:searchString]) if params[:searchString]
      order = 'recent_message_date desc'
      if params[:order].present?
        case params[:order]
        when 'received_asc'
          order = 'recent_message_date asc'
        end
      end

      if current_retailer_user.only_assigned? && current_retailer_user.agent?
        customer_ids = current_retailer_user.a_customers.select(:id)
        customers = customers.where(id: customer_ids)
      end
      customers = customers.group('customers.id')
                           .order(order)
                           .page(params[:page])
      customers
    end

    def send_notification(chat_service)
      agents = @customer.agent.present? ? [@customer.agent] : current_retailer.retailer_users.all_customers.to_a
      data = [
        current_retailer,
        agents,
        nil,
        @customer.agent_customer,
        @customer
      ]

      case chat_service
      when 'facebook'
        FacebookNotificationHelper.broadcast_data(*data)
      when 'whatsapp'
        if current_retailer.karix_integrated?
          KarixNotificationHelper.broadcast_data(*data)
        elsif current_retailer.gupshup_integrated?
          gnhm = Whatsapp::Gupshup::V1::Helpers::Messages.new()
          data = [current_retailer, agents, @customer]
          gnhm.notify_customer_update!(*data)
        end
      end
    end

    def serialize_facebook_messages
      ActiveModelSerializers::SerializableResource.new(
        @messages,
        each_serializer: FacebookMessageSerializer
      ).as_json
    end

    def customer_params
      params.require(:customer).permit(
        :first_name,
        :last_name,
        :email,
        :phone,
        :id_type,
        :id_number,
        :address,
        :city,
        :state,
        :zip_code,
        :country_id,
        :notes,
        :hs_active
      )
    end

    def agents
      current_retailer_user.admin? ||
      current_retailer_user.supervisor? ?
        current_retailer.team_agents :
        [current_retailer_user]
    end
end
