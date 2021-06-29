class Api::V1::DealsController < Api::ApiController
  include CurrentRetailer

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
end
