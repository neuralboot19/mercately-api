class PaymentezTransactionMailer < ApplicationMailer
  def debit_success(transaction)
    @transaction = transaction
    @admin = transaction.retailer.admins.first

    mail to: @admin.email,
         subject: "Gracias por su pago ID: #{@transaction.authorization_code}
                   REF: #{@transaction.transaction_reference}"
  end

  def debit_failure(transaction)
    @transaction = transaction
    @admin = transaction.retailer.admins.first

    mail to: @admin.email,
         subject: 'Su transacción no pudo ser procesada'
  end

  def refund_success(transaction)
    @transaction = transaction
    @admin = transaction.retailer.admins.first

    mail to: @admin.email,
         subject: "La transacción ID: #{@transaction.authorization_code}
                   REF: #{@transaction.transaction_reference}
                   fue devuelta"
  end

  def refund_failure(transaction)
    @transaction = transaction
    @admin = transaction.retailer.admins.first

    mail to: @admin.email,
         subject: 'Su transacción no pudo ser devuelta'
  end
end
