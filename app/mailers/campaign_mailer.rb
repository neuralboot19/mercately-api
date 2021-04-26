class CampaignMailer < ApplicationMailer
  def reminder(campaign, retailer_user)
    @campaign = campaign
    @retailer = campaign.retailer
    @retailer_user = retailer_user

    mail to: @retailer_user.email,
      subject: 'No tienes saldo suficiente para enviar esta campaña'
  end

  def success(campaign, retailer_user)
    @campaign = campaign
    @retailer = campaign.retailer
    @retailer_user = retailer_user

    mail to: @retailer_user.email,
      subject: 'Campaña envíada satisfactoriamente'
  end

  def service_down(campaign, retailer_user)
    @campaign = campaign
    @retailer = campaign.retailer
    @retailer_user = retailer_user

    mail to: @retailer_user.email,
      subject: 'Campaña no envíada, servicio no disponible temporalmente'
  end

  def insufficient_balance(campaign, retailer_user)
    @campaign = campaign
    @retailer = campaign.retailer
    @retailer_user = retailer_user

    mail to: @retailer_user.email,
      subject: 'Campaña no envíada, saldo insuficiente'
  end
end
