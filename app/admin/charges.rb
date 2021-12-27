ActiveAdmin.register PaymentPlan, as: 'Charge' do
  config.sort_order = 'next_pay_date_desc'

  menu label: 'Cobros'
  actions :index, :edit, :update
  permit_params :price, :start_date, :next_pay_date, :status, :plan, :month_interval

  filter :retailer, as: :searchable_select
  filter :next_pay_date
  filter :status, as: :select, collection: PaymentPlan.statuses.keys

  before_action only: :index do
    if params['commit'].blank? && params['q'].blank? && params[:scope].blank?
      params['q'] = { next_pay_date_gteq: 3.months.ago, next_pay_date_lteq: 3.days.from_now }
    end
  end

  controller do
    def scoped_collection
      end_of_association_chain.where.not(next_pay_date: nil)
    end
  end

  index do
    selectable_column
    id_column
    column :price
    column :retailer
    column :next_pay_date
    column :plan
    column :status
    column :month_interval
    column :charge_attempt
    actions
    column :charge do |pp|
      if pp.status_active?
        link_to 'Cobrar', charge_admin_charge_path(pp), method: :post,
          data: { confirm: "Retailer: #{pp.retailer.name}, monto: #{pp.price}, intervalo: #{pp.month_interval} meses, ¿desea cobrar?" }
      else
        link_to 'Cobrar', charge_admin_charge_path(pp), method: :post,
          data: { confirm: "Este plan está inactivo, Retailer: #{pp.retailer.name}, monto: #{pp.price}, intervalo: #{pp.month_interval} meses, ¿desea cobrar?" }
      end
    end
  end

  member_action :charge, method: :post do
    charged = resource.charge!
    msg = case charged
          when true
            'Cobrado exitosamente'
          when false
            'Ocurrió un problema al cobrar'
          else
            'Número de intentos de cobro máximo (4) alcanzado'
          end
    notice_type = charged ? :notice : :error
    redirect_to admin_charges_path, notice_type => msg
  end
end
