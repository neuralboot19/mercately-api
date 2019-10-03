class RetailerMailerPreview < ActionMailer::Preview
  def welcome
    user = RetailerUser.first
    RetailerMailer.welcome(user)
  end
end
