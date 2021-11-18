class Api::V1::DealsController < Api::ApiController
  include CurrentRetailer

  def index
    column = FunnelStep.find_by(web_id: params['column_id'])
    if column
      render status: 200, json:
      {
        deals: set_deals(column, params['page'])
      }
    else
      render status: 422, json: {}
    end
  end

  def destroy
    deal = current_retailer.deals.find_by(web_id: params['id'])
    if deal&.destroy
      render status: 200, json:
      {
        amount: deal.funnel_step.total,
        funnel_step_id: deal.funnel_step.web_id,
        total: deal.funnel_step.deals_count,
        deal: deal
      }
    else
      render status: 422, json: {}
    end
  end

  def customer_deals
    if !current_retailer.has_funnels
      render status: 200, json: []
    else
      deals = Deal.joins(:funnel_step).where(customer_id: params['customer_id'])
          .select('deals.*, funnel_steps.name as funnel_step_name');
      render status: 200, json: deals
    end
  end

  private

    def set_deals(column, page)
      #TODO SET SERIALIZER
      deals = {}

      column.deals.page(params[:page]).offset(false).offset(params[:offset]).each do |deal|
        #TODO FIND A BETTER WAY TO DO THIS
        deals[deal.web_id] = {
          id: deal.web_id,
          name: deal.name,
          amount: deal.amount,
          currency: deal.currency_symbol,
          funnel_step_id: deal.funnel_step_id,
          customer: deal.customer,
          agent: deal.retailer_user,
          channel: deal.customer&.channel
        }
      end
      deals
    end
end
