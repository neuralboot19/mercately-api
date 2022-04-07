class Api::V1::RetailersController < Api::ApiController
  include CurrentRetailer

  def info
    data = {
      id: current_retailer.id,
      name: current_retailer.name,
      slug: current_retailer.slug,
      whatsapp_integrated: current_retailer.whatsapp_integrated?,
      messenger_integrated: current_retailer.facebook_retailer&.connected? || false,
      instagram_integrated: current_retailer.facebook_retailer&.instagram_integrated? || false
    }

    render status: 200, json: { current_retailer: data }
  end
end
