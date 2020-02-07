class Retailers::PaymentPlansController < RetailersController
  include PaymentPlansControllerConcern

  def index
    @payment_plan = PaymentPlan.find_by(retailer_id: current_retailer.id)
    used_karix_whatsapp_messages
  end

  def subscribe
    redirect_to retailers_payment_plans_path(current_retailer), alert: 'Gracias por adquirir tu plan. Puedes continuar usando Mercately libremente.'
  end

  def unsubscribe
    current_retailer.payment_plan.status_cancelled!
    redirect_to retailers_payment_plans_path(current_retailer), alert: 'Plan cancelado'
  end
end
