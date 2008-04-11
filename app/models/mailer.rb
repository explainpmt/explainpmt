class Mailer < ActionMailer::Base

  def forgot_password(user, host)
    @recipients = user.email
    @from = "eXPlainPMT-Admin"
    @subject = "eXPlainPMT Password Reset"
    @content_type = "text/html"
    password = generate_password
    user.temp_password = password
    user.save!
    @body = {:password => password,
      :username => user.username,
      :password_reset_link => url_for(:host => host, :controller => "users",
      :action => "password_reset_confirmation",
      :id => user.id,
      :auth => user.temp_password)}
  end

  private

  def generate_password(length = 8)
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('1'..'9').to_a - ['o', 'O', 'i', 'I']
    Array.new(length) { chars[rand(chars.size)] }.join
  end

end