class PageMailerPreview < ActionMailer::Preview
  def welcome
    user = RetailerUser.first
    PageMailer.welcome(user)
  end
end
