class Retailers::PaymentPlansController < RetailersController
  layout 'chats/chat', only: :index
  include PaymentPlansControllerConcern
  before_action :set_payment_plan, only: [:index, :unsubscribe]

  def index
    @pm = payment_methods

    return unless current_retailer.whatsapp_integrated?

    used_whatsapp_messages
    bot_interactions_counter
  end

  def subscribe
    redirect_to retailers_payment_plans_path(current_retailer), alert: 'Gracias por adquirir tu plan. ' \
      'Puedes continuar usando Mercately libremente.'
  end

  def unsubscribe
    @payment_plan.status_inactive!
    redirect_to retailers_payment_plans_path(current_retailer), notice: 'Plan cancelado con éxito'
  end

  private

    def set_payment_plan
      @payment_plan = PaymentPlan.find_by(retailer_id: current_retailer.id)
    end

    def payment_methods
      current_retailer.ecu_charges ?
        current_retailer.paymentez_credit_cards :
        current_retailer.payment_methods
    end
end
