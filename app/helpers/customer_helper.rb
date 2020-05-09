module CustomerHelper
  def customer_ordering_options
    [{ value: 'created_at asc', label: 'Fecha de creación Asc' }, { value: 'created_at desc', label:
       'Fecha de creación Desc' }, { value: 'first_name asc', label: 'Nombres Asc' }, { value:
       'first_name desc', label: 'Nombres Desc' }, { value: 'email asc', label: 'Email Asc' }, { value:
       'email desc', label: 'Email Desc' }, { value: 'phone asc', label: 'Teléfono Asc' }, { value:
       'phone desc', label: 'Teléfono Desc' }, { value: 'sort_by_completed_orders desc', label:
       'Ventas completadas' }, { value: 'sort_by_pending_orders desc', label: 'Ventas pendientes' }, { value:
       'sort_by_canceled_orders desc', label: 'Ventas canceladas' }, { value: 'sort_by_total asc', label:
       'Total Asc' }, { value: 'sort_by_total desc', label: 'Total Desc' }]
  end

  def can_send_whatsapp_notification?(retailer_user, customer)
    agent_or_asigned = retailer_user.agent? && retailer_user.customers.select { |c| c.id == customer.id }.any?
    return false unless retailer_user.admin? || ( agent_or_asigned )

    return true if retailer_user.retailer.gupshup_integrated? && customer.whatsapp_opt_in == true

    retailer_user.retailer.karix_integrated? && customer.phone.present? && customer.phone[0] == '+'
  end
end
