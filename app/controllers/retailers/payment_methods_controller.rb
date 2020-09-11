class Retailers::PaymentMethodsController < RetailersController
  before_action :load_stripe_api_key

  def create_setup_intent
    retailer = Retailer.find_by(slug: params[:slug])
    payment_methods = PaymentMethod.find_by(retailer_id: retailer.id)

    id = if payment_methods.nil?
      get_stripe_customer_id(retailer)
    else
      payload_data = JSON.parse(payment_methods.payment_payload)
      payload_data['customer']
    end

    data = Stripe::SetupIntent.create(
      customer: id
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
      update_stripe_customer(stripe_pm['customer'],params['payment_method'])

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

    def get_stripe_customer_id(retailer)
      customers_stripe = Stripe::Customer.list()
      descrip = retailer.name
      email = current_retailer_user.email

      customers_stripe.each do |customer|
        if customer['email'] == email && customer['description'] == descrip
          return customer['id']
        end
      end

      customer = Stripe::Customer.create({
        description: descrip,
        email: email
      })

      customer['id']
    end

    def update_stripe_customer(customer_id, payment_method_id )
      Stripe::Customer.update(
        customer_id,
        {
          'invoice_settings': {
            'default_payment_method': payment_method_id,
          },
        }
      )
    rescue StandardError => e
      raise e
    end
end
