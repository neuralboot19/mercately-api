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

  def broken_hs_integration(retailer_user)
    @retailer = retailer_user.retailer

    I18n.with_locale(retailer_user.locale) do
      mail to: retailer_user.email, subject: t('mailer.broken_hs_integration.broken_integration')
    end
  end

  def running_out_balance(retailer, email)
    @retailer = retailer
    mail to: email, subject: 'Su saldo está a punto de terminarse'
  end

  def imported_customers(retailer_user, errors)
    @errors = errors

    mail to: retailer_user.email, subject: 'Importación de Clientes Completa'
  end

  def imported_contact_group(retailer_user, contact_group, errors)
    @contact_group = contact_group
    @errors = errors

    mail to: retailer_user.email, subject: 'Importación y creación de grupo de clientes completa'
  end

  def failed_import(retailer_user, errors)
    @errors = errors

    mail to: retailer_user.email, subject: 'La importación de clientes ha fallado'
  end

  def failed_charge(retailer, retailer_user, card_type)
    @retailer = retailer
    @card_type = card_type
    @retailer_user = retailer_user

    I18n.with_locale(@retailer_user.locale) do
      mail to: retailer_user.email, subject: t('mailer.failed_charge_subject')
    end
  end
end
