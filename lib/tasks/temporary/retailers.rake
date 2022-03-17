namespace :retailers do
  task create_funnels: :environment do
    FunnelStep.all.find_each do |fs|
      fs.deals.each_with_index do |d, i|
        d.update_column(:position, i)
      end
    end
    Retailer.all.find_each(&:create_funnel_steps)
  end

  task set_last_card_main: :environment do
    Retailer.joins(:payment_methods).find_each do |r|
      r.payment_methods.last.main!
    end
  end

  # Este método calcula el intervalo en meses entre un pago y otro
  # si el pago es el último, se asigna el intervalo del payment_plan
  task set_month_interval_payment_history: :environment do
    # Se toman los nombres de las transacciones
    [:stripe_transactions, :paymentez_transactions].each do |method_name|
      # Se hace un join entre los retailers y la transaccion en particular
      Retailer.joins(method_name).each do |r|
        # Se obtienen y ordenan las transacciones de un retailer en especifico
        transactions = r.send(method_name).order(:id)
        transactions.each_with_index do |t, i|
          date1 = t.created_at
          date2 = transactions[i + 1]&.created_at
          month_interval = if date2.nil?
                             r.payment_plan.month_interval
                           else
                             # Se calcula la diferencia entre los pagos teniendo en cuenta el año y el día
                             # esto para casos como un pago entre diciembre y enero, la diferencia es de 1 mes
                             # pero si se hace la resta 1 - 12 = -11
                             # Por último, se toma su valor absoluto para que siempre sea positivo el intervalo
                             ((date2.year - date1.year) * 12 + date2.month - date1.month - (date2.day >= date1.day ? 0 : 1)).abs
                           end
          # Si el pago es menor a 70 se asume que fue una recarga de saldo,
          # ya que por ahora es el plan de menor precio
          month_interval = 0 if t.amount < 70
          t.update_column(:month_interval, month_interval)
          t.send :generate_web_id
        end
      end
    end
  end

  task generate_catalog_slug: :environment do
    errors = []
    Retailer.joins(:payment_plan).where(payment_plans: { status: :active }, shop_updated: false).find_each do |r|
      r.send :set_catalog_slug
      r.update_column :catalog_slug, r.catalog_slug
      r.send :create_shop
    rescue => e
      errors << [r.id, e]
    end

    puts errors
  end
end
