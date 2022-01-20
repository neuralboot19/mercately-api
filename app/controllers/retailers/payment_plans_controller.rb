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

  def invoice
    @transaction = current_retailer.stripe_transactions.find_by_web_id(params[:id])
    @transaction = current_retailer.paymentez_transactions.find_by_web_id(params[:id]) if @transaction.nil?
    @retailer_admin = RetailerUser.active_admins(current_retailer.id).first
    @bill_details = current_retailer.retailer_bill_detail
    render layout: 'document'
  end

  def charge
    pp = current_retailer.payment_plan
    alert = if pp.charge!(force_retry: true)
              pp.status_active!
              'Plan reactivado exitosamente.'
            else
              'Ocurrió un error al cobrar.'
            end
    redirect_to retailers_payment_plans_path(current_retailer), notice: alert
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
