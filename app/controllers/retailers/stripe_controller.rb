class Retailers::StripeController < RetailersController
  def add_balance
    pm = PaymentMethod.find_by(stripe_pm_id: params[:card][:cc_id])
    st = StripeTransaction.new(
      retailer_id: current_retailer.id,
      amount: params[:card][:amount],
      payment_method: pm
    )

    if st.save
      flash[:notice] = 'Saldo agregado exitosamente'
      render status: 200, json: { message: 'Saldo agregado exitosamente' }
    else
      error_msg = st.errors.values.join(', ')
      flash[:notice] = error_msg
      render status: 500, json: { message: error_msg }
    end
  end
end
