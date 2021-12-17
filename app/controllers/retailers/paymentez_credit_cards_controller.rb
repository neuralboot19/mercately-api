class Retailers::PaymentezCreditCardsController < RetailersController
  skip_before_action :validate_payment_plan, only: :set_default
  before_action :set_card

  def set_default
    notice = if @pcc&.set_default
               t('retailer.paymentez.updated_card_success')
             else
               t('retailer.paymentez.updated_card_error')
             end

    redirect_to retailers_payment_plans_path(current_retailer), notice: notice
  end

  private

    def set_card
      @pcc = current_retailer.paymentez_credit_cards.find_by_id(params[:id])
    end
end
