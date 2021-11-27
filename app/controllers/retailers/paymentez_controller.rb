class Retailers::PaymentezController < RetailersController
  skip_before_action :validate_payment_plan, only: [:create, :purchase_plan, :destroy]
  before_action :validate_terms, only: :purchase_plan

  def create
    type = paymentez_params[:type]
    paymentez_card = current_retailer.paymentez_credit_cards.new(
      paymentez_params.except(:type)
                      .merge(
                        card_type: type,
                        name: params[:holder_name]
                      )
    )

    if paymentez_card.save
      return if purchasing_plan?(paymentez_card)

      flash[:notice] = t('retailer.paymentez.added_card_success')
      render status: 200, json: {
        notice: t('retailer.paymentez.added_card_success')
      } and return
    end

    flash[:notice] = t('retailer.paymentez.added_card_error')
    render status: 500, json: { notice: t('retailer.paymentez.added_card_error') }
  end

  def destroy
    pcc = set_card(params['id'])

    redirect_path = retailers_payment_plans_path(current_retailer)

    if pcc && current_retailer.paymentez_credit_cards.count > 1 && pcc.delete_card!
      redirect_to redirect_path, notice: t('retailer.paymentez.deleted_card_success')
      return
    end

    redirect_to redirect_path, notice: t('retailer.paymentez.deleted_card_error')
  end

  def add_balance
    pcc = set_card(purchase_params['cc_id'])

    if pcc.create_transaction_with_amount(purchase_params['amount'].to_f)
      flash[:notice] = t('retailer.paymentez.added_balance_success')
      render status: 200, json: {
        message: t('retailer.paymentez.added_balance_success')
      } and return
    end

    flash[:notice] = t('retailer.paymentez.added_balance_error')
    render status: 500, json: { message: t('retailer.paymentez.added_balance_error') }
  end

  def purchase_plan
    pcc = set_card(purchase_params['cc_id'])

    if pcc.create_transaction_with_plan(purchase_params)
      flash[:notice] = 'Plan activado exitosamente'
      render status: 200, json: {
        message: 'Plan activado exitosamente'
      } and return
    end

    flash[:notice] = 'Error al activar plan'
    render status: 500, json: { message: 'Error al activar plan' }
  end

  private
    def paymentez_params
      params.require(:cardToken).permit(
        :token,
        :status,
        :expiry_year,
        :expiry_month,
        :type,
        :number
      )
    end

    def purchase_params
      params.require(:card).permit(
        :amount,
        :cc_id,
        :plan,
        :terms
      )
    end

    def validate_terms
      return true if purchase_params.try(:[], :terms) == 'true'

      flash[:notice] = 'Usted debe aceptar los términos y condiciones'
      render status: 500, json: {
        message: 'Usted debe aceptar los términos y condiciones'
      }
    end

    def purchasing_plan?(paymentez_card)
      # Checking if is purchasing a plan
      amount = params.try(:[], :card).try(:[], :amount)
      plan = params.try(:[],:card).try(:[],:plan)

      if amount && plan
        if paymentez_card.create_transaction_with_plan(params[:card])
          flash[:notice] = 'Plan activado exitosamente'
          render status: 200, json: {
            message: 'Plan activado exitosamente'
          }
        else
          flash[:notice] = 'Error al activar plan'
          render status: 500, json: { message: 'Error al activar plan' }
        end
        # returns true if it is actually purchasing a plan
        return true
      end

      return false
    end

    def set_card(id)
      current_retailer.paymentez_credit_cards
                      .find_by(id: id.to_i)
    end
end
