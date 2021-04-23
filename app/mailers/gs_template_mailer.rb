class GsTemplateMailer < ApplicationMailer
  def accepted(id, retailer_user)
    @gs_template = GsTemplate.find(id)
    @retailer_user = retailer_user

    mail to: @retailer_user.email,
         subject: 'Plantilla aceptada'
  end

  def submitted(id, retailer_user)
    @gs_template = GsTemplate.find(id)
    @retailer_user = retailer_user

    mail to: @retailer_user.email,
         subject: 'Plantilla enviada a revisión'
  end

  def rejected(id, retailer_user)
    @gs_template = GsTemplate.find(id)
    @retailer_user = retailer_user

    mail to: @retailer_user.email,
         subject: 'Plantilla rechazada'
  end
end
