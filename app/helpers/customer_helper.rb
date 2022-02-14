module CustomerHelper
  def customer_ordering_options
    [{ value: 'created_at asc', label: 'Fecha de creación Asc' }, { value: 'created_at desc', label:
       'Fecha de creación Desc' }, { value: 'first_name asc', label: 'Nombres Asc' }, { value:
       'first_name desc', label: 'Nombres Desc' }, { value: 'email asc', label: 'Email Asc' }, { value:
       'email desc', label: 'Email Desc' }, { value: 'phone asc', label: 'Teléfono Asc' }, { value:
       'phone desc', label: 'Teléfono Desc' }, { value: 'sort_by_completed_orders desc', label:
       'Órdenes completadas' }, { value: 'sort_by_pending_orders desc', label: 'Órdenes pendientes' }, { value:
       'sort_by_canceled_orders desc', label: 'Órdenes canceladas' }, { value: 'sort_by_total asc', label:
       'Total Asc' }, { value: 'sort_by_total desc', label: 'Total Desc' }]
  end

  def can_send_whatsapp_notification?(retailer_user, customer)
    return false unless customer.phone.present?
    return retailer_user.a_customers.where(id: customer.id).exists? if retailer_user.agent? && retailer_user.only_assigned
    return true if retailer_user.retailer.gupshup_integrated?

    agent_or_asigned = retailer_user.agent? && retailer_user.customers.select { |c| c.id == customer.id }.any?
    return false unless retailer_user.admin? || retailer_user.supervisor? || agent_or_asigned

    retailer_user.retailer.karix_integrated? && customer.phone.present? && customer.phone[0] == '+'
  end

  def retailer_selectable_tags(retailer)
    retailer.tags.map { |tag| [tag.tag, tag.id] }
  end

  def agents_allowed
    current_retailer_user.admin? ||
    current_retailer_user.supervisor? ?
      agent_names(current_retailer.team_agents) :
      [[name(current_retailer_user), current_retailer_user.id]]
  end

  def groups_allowed
    current_retailer.contact_groups.map {|group| [group.name, group.id ]  }
  end

  def customer_columns_list
    fields = [
      ['Nombres', 'first_name'],
      ['Apellidos', 'last_name'],
      ['Email', 'email'],
      ['Identificación', 'id_number'],
      ['Dirección', 'address'],
      ['Ciudad', 'city'],
      ['Estado (Provincia)', 'state'],
      ['Zip', 'zip_code']
    ]

    fields += current_retailer.customer_related_fields.map { |crf| [crf.name, crf.identifier] }
    fields.compact
  end

  private

  def agent_names(agents)
    agents.map { |agent| [name(agent), agent.id] }
  end

  def name(user)
    return "#{user.full_name} - #{user.email}" unless user.full_name.strip.empty?

    user.email
  end

  def field_types_list
    CustomerRelatedField.field_types.keys.collect { |f| [CustomerRelatedField.enum_translation(:field_type, f), f] }
  end

  def hubspot_matches_list
    Retailer.hubspot_matches.keys.collect { |f| [Retailer.enum_translation(:hubspot_match, f), f] }
  end
end
