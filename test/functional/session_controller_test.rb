require File.dirname(__FILE__) + '/../test_helper'
require 'session_controller'

# Re-raise errors caught by the controller.
class SessionController; def rescue_action(e) raise e end; end

class SessionControllerTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES
  
  def setup
    @user_one = User.find 2
    @controller = SessionController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_login
    get :login
    assert_template 'login'
  end

  def test_authenticate
    post :authenticate, 'username' => @user_one.username,
      'password' => @user_one.password
    assert_equal @user_one, session[ :current_user ]
    assert_redirected_to :controller => 'dashboard', :action => 'index'
  end

  def test_authenticate_with_return_to
    @request.session[ :return_to ] = '/foo/bar'
    post :authenticate, 'username' => @user_one.username,
      'password' => @user_one.password
    assert_redirect_url 'http://test.host/foo/bar'
  end

  def test_authenticate_failed
    post :authenticate
    assert_redirected_to :controller => 'session', :action => 'login'
    assert_nil session[ :current_user ]
    assert_equal "You entered an invalid username and/or password.",
      flash[ :error ]
  end

  def test_logout
    @request.session[ :current_user ] = @user_one
    get :logout
    assert_nil session[ :current_user ]
    assert_redirected_to :controller => 'session', :action => 'login'
    assert_equal "You have been logged out.", flash[ :status ]
  end
end
