class RetailerMailer < ApplicationMailer
  def welcome(user)
    @user = user

    mail to: user.email, subject: 'Bienvenido a Mercately'
  end

  def invitation(user)
    @user = user

    mail to: user.email, subject: "#{@user.retailer.name} te ha invitado a su equipo en Mercately"
  end

  def export_customers(retailer, retailer_email, file, type)
    @retailer = retailer
    @retailer_email = retailer_email

    if type == 'csv'
      content_type = 'text/csv'
      extension = 'csv'
    elsif type == 'excel'
      content_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      extension = 'xlsx'
    end

    attachments["Customers.#{extension}"] = { mime_type: content_type, content: file }
    mail to: retailer_email, subject: 'Mercately Exportación de Clientes Completa'
  end

  def chat_assignment_notification(agent_customer, retailer_user)
    @agent_customer = agent_customer
    @retailer_user = retailer_user
    mail to: agent_customer.retailer_user.email, subject: 'Nuevo chat asignado'
  end

  def running_out_balance(retailer)
    @retailer = retailer
    mail to: retailer.admins.pluck(:email), subject: 'Su saldo está a punto de terminarse'
  end

  def imported_customers(retailer_user, errors)
    @errors = errors

    mail to: retailer_user.email, subject: 'Importación de Clientes Completa'
  end
end
