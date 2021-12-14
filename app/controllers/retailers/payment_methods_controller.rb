class Retailers::PaymentMethodsController < RetailersController
  skip_before_action :validate_payment_plan, only: [:create, :create_setup_intent, :destroy]

  def create_setup_intent
    retailer = Retailer.find_by(slug: params[:slug])
    payment_methods = PaymentMethod.find_by(retailer_id: retailer.id)

    id = if payment_methods.nil?
           get_stripe_customer_id(retailer)
         else
           payload_data = JSON.parse(payment_methods.payment_payload)
           payload_data['customer']
         end

    data = Stripe::SetupIntent.create(customer: id)

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
      update_stripe_customer(stripe_pm['customer'], params['payment_method'])

      flash[:notice] = t('retailer.payment_methods.added_payment_method_success')
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

    if pm && current_retailer.payment_methods.count > 1
      pm.destroy
      Stripe::PaymentMethod.detach(pm.stripe_pm_id)
      redirect_to redirect_path, notice: t('retailer.payment_methods.deleted_payment_method_success')
      return
    end

    redirect_to redirect_path, alert: t('retailer.payment_methods.payment_method_not_found')
  end

  private

    def get_stripe_customer_id(retailer)
      customers_stripe = Stripe::Customer.list
      desc = retailer.name
      email = current_retailer_user.email

      customers_stripe.each do |customer|
        return customer['id'] if customer['email'] == email && customer['description'] == desc
      end

      customer = Stripe::Customer.create(
        description: desc,
        email: email
      )

      customer['id']
    end

    def update_stripe_customer(customer_id, payment_method_id)
      Stripe::Customer.update(
        customer_id,
        invoice_settings: {
          default_payment_method: payment_method_id
        }
      )
    rescue StandardError => e
      Raven.capture_exception(e)
      raise e
    end
end
