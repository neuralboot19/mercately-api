class RequestDemoMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.request_demo_mailer.demo_requested.subject
  #
  def demo_requested(client_data)
    @name = client_data[:name]
    @email = client_data[:email]
    @company = client_data[:company]
    @phone = client_data[:phone]
    @message = client_data[:message]

    mail to: 'hola@mercately.com, henry2992@hotmail.com, pvelasquez9294@gmail.com, jalagut8@gmail.com',
         subject: "Mercately demo requested by #{@name}"
  end
end
