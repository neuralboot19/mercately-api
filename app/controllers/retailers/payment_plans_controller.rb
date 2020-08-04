class Retailers::PaymentPlansController < RetailersController
  include PaymentPlansControllerConcern

  def index
    @payment_plan = PaymentPlan.find_by(retailer_id: current_retailer.id)
    @pm = payment_methods

    used_whatsapp_messages if current_retailer.whatsapp_integrated?
  end

  def subscribe
    redirect_to retailers_payment_plans_path(current_retailer), alert: 'Gracias por adquirir tu plan. ' \
      'Puedes continuar usando Mercately libremente.'
  end

  def unsubscribe
    current_retailer.payment_plan.status_cancelled!
    redirect_to retailers_payment_plans_path(current_retailer), alert: 'Plan cancelado'
  end

  private
    def payment_methods
      current_retailer.ecu_charges ?
        current_retailer.paymentez_credit_cards :
        current_retailer.payment_methods
    end
end
