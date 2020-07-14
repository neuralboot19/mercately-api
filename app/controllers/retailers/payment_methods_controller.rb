class Retailers::PaymentMethodsController < RetailersController
  before_action :load_stripe_api_key

  def create_setup_intent
    customer = Stripe::Customer.create

    data = Stripe::SetupIntent.create(
      customer: customer['id']
    )

    render status: 200, json: { data: data.as_json }
  end

  def create
    stripe_pm = Stripe::PaymentMethod.retrieve(params['payment_method'])

    pm = current_retailer.payment_methods.new do |p|
      p.stripe_pm_id = params['payment_method']
      p.payment_type = stripe_pm['type']
      p.payment_payload = stripe_pm.to_json
    end

    if pm.save
      flash[:notice] = 'Método de pago almacenado con éxito.'
      render status: 200, json: {
        data: pm.payment_payload
      }
      return
    end

    render status: 500, json: { data: pm.errors.full_messages }
  rescue Stripe::InvalidRequestError => e
    render status: 500, json: { data: e.message }
  end

  def destroy
    pm = current_retailer.payment_methods.find_by(stripe_pm_id: params['id'])
    redirect_path = retailers_payment_plans_path(current_retailer)

    if pm
      pm.destroy
      Stripe::PaymentMethod.detach(pm.stripe_pm_id)
      redirect_to redirect_path, notice: 'Método de pago eliminado con éxito.'
      return
    end

    redirect_to redirect_path, alert: 'Método de pago no encontrado.'
  end

  private

    def load_stripe_api_key
      Stripe.api_key = ENV['STRIPE_SECRET']
    end
end
