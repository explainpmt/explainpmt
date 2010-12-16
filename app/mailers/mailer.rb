class Mailer < ActionMailer::Base

  ## TODO => implement this using authlogic perishable_token.
  def forgot_password(user, host)
    # @recipients = user.email
    # @from = "eXPlainPMT-Admin"
    # @subject = "eXPlainPMT Password Reset"
    # @content_type = "text/html"
    # password = generate_password
    # user.temp_password = password
    # user.save!
    # @body = {:password => password,
    #   :username => user.username,
    #   :password_reset_link => url_for(:host => host, :controller => "users",
    #   :action => "password_reset_confirmation",
    #   :id => user.id,
    #   :auth => user.temp_password)}
  end

end