class RetailerMailer < ApplicationMailer
  def welcome(user)
    @user = user

    mail to: user.email, subject: 'Bienvenido a Mercately'
  end

  def invitation(user)
    @user = user

    mail to: user.email, subject: "#{@user.retailer.name} te ha invitado a su equipo en Mercately"
  end

  def export_customers(retailer, retailer_email, csv_file)
    @retailer = retailer
    @retailer_email = retailer_email

    attachments['customers.csv'] = { mime_type: 'text/csv', content: csv_file }
    mail to: retailer_email, subject: 'Mercately Exportación de Clientes Completa'
  end
end
