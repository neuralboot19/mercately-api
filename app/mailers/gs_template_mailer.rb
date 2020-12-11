class GsTemplateMailer < ApplicationMailer
  def accepted(id)
    @gs_template = GsTemplate.find(id)
    @retailer = @gs_template.retailer

    mail to: @retailer.admins.pluck(:email),
      subject: 'Plantilla aceptada'
  end

  def submitted(id)
    @gs_template = GsTemplate.find(id)
    @retailer = @gs_template.retailer

    mail to: @gs_template.retailer.admins.pluck(:email),
      subject: 'Plantilla enviada a revisión'
  end

  def rejected(id)
    @gs_template = GsTemplate.find(id)
    @retailer = @gs_template.retailer

    mail to: @gs_template.retailer.admins.pluck(:email),
      subject: 'Plantilla rechazada'
  end
end
