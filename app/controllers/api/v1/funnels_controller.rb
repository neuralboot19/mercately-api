class Api::V1::FunnelsController < Api::ApiController
  include CurrentRetailer
  before_action :set_current_funnel

  def index
    columns = set_columns(@funnel.funnel_steps)
    data = {
      deals: set_deals,
      columns: columns,
      columnOrder: set_column_order
    }

    render status: 200, json: { funnelSteps: data }
  end

  # TODO: move to deals controller
  def update_deal
    deal = Deal.find_by(web_id: params['deal']['deal_id'])
    funnel_step = FunnelStep.find_by(web_id: params['deal']['funnel_step_id'])

    if deal && funnel_step
      previous_funnel_step = deal.funnel_step
      deal.update(funnel_step_id: funnel_step.id)
      deal.update(deal_params.except(:funnel_step_id))
      render status: 200, json: {
        deal_id: deal.web_id,
        funnel_step_id: funnel_step.web_id,
        position: deal.position,
        previous_funnel_step_amount: previous_funnel_step.total,
        amount: funnel_step.total,
        currency: funnel_step.currency_symbol,
        previous_funnel_step_total: previous_funnel_step.deals.count,
        total: funnel_step.deals.count,
        deal: {
          id: deal.web_id,
          name: deal.name,
          currency: deal.currency_symbol,
          amount: deal.amount,
          funnel_step_id: deal.funnel_step_id,
          retailer_id: deal.retailer_id,
          customer: deal.customer,
          agent: deal.retailer_user,
          channel: deal.customer&.channel
        }
      }
    else
      render status: 404, json: {}
    end
  end

  def update_funnel_step
    if @funnel.update_column_order(params['funnel_step']['columns'])
      render status: 200, json: {}
    end
  end

  # TODO: move to deals controller
  def create_deal
    deal = Deal.new(deal_params)
    if deal.save
      render status: 200, json:
      {
        deal_id: deal.web_id,
        funnel_step_id: deal.funnel_step.web_id,
        amount: deal.funnel_step.total,
        deal: {
          id: deal.web_id,
          name: deal.name,
          amount: deal.amount,
          currency: deal.currency_symbol,
          funnel_step_id: deal.funnel_step_id,
          retailer_id: deal.retailer_id,
          agent: deal.retailer_user,
          customer: deal.customer,
          channel: deal.customer&.channel
        }
      }
    else
      render status: 422, json: {}
    end
  end

  def create_step
    funnel_step = @funnel.funnel_steps.build(funnel_step_params)

    if funnel_step.save
      render status: 200, json:
      {
        step: {
          id: funnel_step.web_id,
          title: funnel_step.name,
          deals: funnel_step.deals.count,
          dealIds: funnel_step.deals.pluck(:web_id).map(&:to_s),
          internal_id: funnel_step.id,
          r_internal_id: @funnel.retailer_id
        }
      }
    else
      render status: 422, json: {}
    end
  end

  def delete_step
    funnel_step = FunnelStep.find_by(web_id: params['id'])

    if funnel_step.destroy
      render status: 200, json:
      {
        funnel_step: {
          id: funnel_step.web_id
        }
      }
    else
      render status: 422, json: {}
    end
  end

  private

    def set_current_funnel
      @funnel = current_retailer.current_funnel

      render status: 404, json: { message: 'Funnel does not exist' } unless @funnel
    end

    # TODO: move to deals controller
    def set_deals
      #TODO SET SERIALIZER
      deals = {}

      @funnel.funnel_steps.each do |f_step|
        #TODO FIND A BETTER WAY TO DO THIS
        f_step.deals.page(1).each do |deal|
          deals[deal.web_id] = {
            id: deal.web_id,
            name: deal.name,
            amount: deal.amount,
            currency: deal.currency_symbol,
            funnel_step_id: deal.funnel_step_id,
            agent: deal.retailer_user,
            customer: deal.customer,
            channel: deal.customer&.channel
          }
        end
      end
      deals
    end

    def set_columns(funnel_steps)
      columns = {}
      funnel_steps.each do |step|
        columns[step.web_id] = {
          id: step.web_id.to_s,
          title: step.name,
          deals: step.deals.page.count,
          dealIds: step.deals.page(1).pluck(:web_id).map(&:to_s),
          internal_id: step.id,
          r_internal_id: @funnel.retailer_id,
          total: step.deals.count,
          pages: (step.deals.count / Deal::PAGINATES_PER) + 1,
          currency: step.currency_symbol,
          amount: step.total
        }
      end

      columns
    end

    def set_column_order
      @funnel.funnel_steps.order(:position).pluck(:web_id).map(&:to_s)
    end

    # TODO: move to deals controller
    def deal_params
      params.require(:deal).permit(
        :name,
        :amount,
        :position,
        :funnel_step_id,
        :retailer_id,
        :retailer_user_id,
        :customer_id
      )
    end

    def funnel_step_params
      params.require(:funnel_step).permit(
        :name
      )
    end
end
