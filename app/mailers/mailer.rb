class Mailer < ActionMailer::Base
  default :from => "eXPlainPMT <noreply@explainpmt.com>"
  ## TODO => put this in config or something.
  default_url_options[:host] = 'explainpmt.com'
  
  def password_reset_instructions(user)
    @reset_password_link = reset_password_users_url(:token => user.perishable_token)
    @user = user
    mail(:to => user.email, :subject => "eXPlainPMT | Password Reset Instructions")
  end
end