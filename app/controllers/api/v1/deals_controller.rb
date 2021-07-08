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
        deal: deal
      }
    else
      render status: 422, json: {}
    end
  end

  private

    def set_deals(column, page)
      #TODO SET SERIALIZER
      deals = {}

      column.deals.page(params['page']).each do |deal|
        #TODO FIND A BETTER WAY TO DO THIS
        deals[deal.web_id] = {
          id: deal.web_id,
          name: deal.name,
          amount: deal.amount,
          customer: deal.customer,
          has_whastapp: deal&.customer&.ws_active,
          has_fb: deal&.customer&.psid
        }
      end
      deals
    end
end
