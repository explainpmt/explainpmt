require 'test_helper'

class MailerTest < ActionMailer::TestCase
  
  CHARSET = 'UTF-8'
  
  context "forgot password" do
    setup do
      @user = User.create(valid_user_params)
      @expected = Mail.new
      @expected.content_type = 'text/plain'
      @expected.charset = CHARSET
      @expected.mime_version = '1.0'
    end
    
    should "send password reset instructions" do
      @expected.from    = "eXPlainPMT <noreply@explainpmt.com>"
      @expected.to      = @user.email
      @expected.subject = "eXPlainPMT | Password Reset Instructions"
      
      assert_equal @expected, Mailer.password_reset_instructions(@user)
    end
    
  end
  
end
