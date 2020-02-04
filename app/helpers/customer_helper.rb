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
end
