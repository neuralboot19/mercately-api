class RequestDemoMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.request_demo_mailer.demo_requested.subject
  #
  def demo_requested(demo_request_lead)
    @demo_request_lead = demo_request_lead

    mail to: 'hola@mercately.com, henry2992@hotmail.com, pvelasquez9294@gmail.com, jalagut8@gmail.com',
         subject: "Mercately demo requested by #{@demo_request_lead.name}"
  end
end
