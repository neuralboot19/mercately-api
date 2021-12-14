class Retailers::PlanCancellationsController < RetailersController
  def create
    if current_retailer.payment_plan.status_inactive!
      @cancellation = current_retailer.plan_cancellations.create(plan_cancellation_params)

      flash[:notice] = t('retailer.plan_cancellations.canceled_plan_success')
      render status: 200, json: { message: t('retailer.plan_cancellations.canceled_plan_success') }
    else
      flash[:notice] = t('retailer.plan_cancellations.canceled_plan_error')
      render status: 500, json: { message: t('retailer.plan_cancellations.canceled_plan_error') }
    end
  end

  private

    def plan_cancellation_params
      params.require(:plan_cancellation).permit(
        :reason,
        :comment
      )
    end
end
