class RetailerMailer < ApplicationMailer
  def welcome(user)
    @user = user

    mail to: user.email, subject: 'Bienvenido a Mercately'
  end

  def invitation(user)
    @user = user
    @invitation_link = accept_retailer_user_invitation_url(invitation_token: @user.raw_invitation_token)

    mail to: user.email, subject: "#{@user.retailer.name} te ha invitado a su equipo en Mercately"
  end
end
