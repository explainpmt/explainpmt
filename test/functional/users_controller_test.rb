require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @admin      = User.find(1)
    @user       = User.find(2)
  end

  def test_index_for_admin
    @request.session[ :current_user_id ] = @admin.id
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_index_for_user
    @request.session[ :current_user_id ] = @user.id
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'no_admin'
    assert_equal 'You must be logged in as an administrator to perform'+
                  ' this action', flash[ :error ]
  end

  def test_list
    @request.session[ :current_user_id ] = @admin.id
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:users)
  end

  def test_show_to_user
    @request.session[ :current_user_id ] = @user.id
    get :show, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'no_admin'
    assert_equal 'You must be logged in as an administrator to perform'+
                  ' this action', flash[ :error ]  
  end
  
  def test_show_self_user
    @request.session[ :current_user_id ] = @user.id
    get :show, :id => 2
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:user)
    assert assigns(:user).valid? 
  end

  def test_show_to_admin
    @request.session[ :current_user_id ] = @admin.id
    get :show, :id => 1
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:user)
    assert assigns(:user).valid?  
  end

  def test_new_using_admin
    @request.session[ :current_user_id ] = @admin.id
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:user)
  end
  
  def test_new_using_user
    @request.session[ :current_user_id ] = @user.id
    get :new
    assert_response :redirect
    assert_redirected_to :action => 'no_admin'
    assert_equal 'You must be logged in as an administrator to perform'+
                  ' this action', flash[ :error ]
  end

  def test_create
    @request.session[ :current_user_id ] = @admin.id
    
    num_users = User.count

    post :create, :user => {
      'login' => 'test_create', 'password' => 'password',
      'password_confirmation' => 'password', 'email' => 'test@example.com',
      'name' => 'Test Create'
    }

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_users + 1, User.count
  end

  def test_edit_from_user
    @request.session[ :current_user_id ] = @user.id
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'no_admin'
    assert_equal 'You must be logged in as an administrator to perform'+
                  ' this action', flash[ :error ]
  end
  
  def test_edit_from_admin
    @request.session[ :current_user_id ] = @admin.id
    get :edit, :id => 1
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end
  
  def test_edit_self_from_user
    @request.session[ :current_user_id ] = @user.id
    get :edit, :id => 2
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_update
    @request.session[ :current_user_id ] = @admin.id
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    @request.session[ :current_user_id ] = @admin.id

    assert_not_nil User.find(3)

    post :destroy, :id => 3
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      User.find(3)
    }
  end
  
  def test_destroy_self_from_user
    @request.session[ :current_user_id ] = @user.id
    assert_not_nil User.find(2)
    post :destroy, :id => 2
    assert_response :redirect
    assert_redirected_to :action => 'no_admin'
    assert_equal 'You must be logged in as an administrator to perform'+
                  ' this action', flash[ :error ]
    assert_equal "user", User.find(2).login  
  end

  def test_destroy_self_from_admin
    @request.session[ :current_user_id ] = @admin.id
    assert_not_nil User.find(1)
    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_equal 'You may not delete your own account', flash[ :error ]
    assert_equal "admin", User.find(1).login  
  end
  
  def test_destroy_last_admin
    # This should never happen as in order to destroy the last admin, an admin
    # must be logged in and destroy themselves.  This would trigger the branch
    # of any user destroying themselves.  But it is included here for 
    # completeness.
    @request.session[ :current_user_id ] = @admin.id
    # First remove the first admin of the two
    assert_not_nil User.find(3)
    post :destroy, :id => 3
    assert_response :redirect
    assert_redirected_to :action => 'list'
    # Check that the first admin was removed
    assert_raise(ActiveRecord::RecordNotFound) {
      User.find(3)
    }
    # Now try to remove the final admin
    assert_not_nil User.find(1)
    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'
    # Here is where it hits the Destroying of their own account.  The next
    # commented code would then catch the deletion of the last admin account 
    # if users were allowed to delete themselves.
    assert_equal 'You may not delete your own account', flash[ :error ]  
    #assert_equal 'You may not delete the last admin account', flash[ :error ]
    assert_equal "admin", User.find(1).login 
  end
  
  def test_login
    get :login
    assert_template 'login'
  end
  
  def test_authenticate
    post :authenticate, 'login' => @admin.login, 'password' => @admin.password
    assert_equal @admin.id, session[ :current_user_id ]
    assert_response :redirect
    assert_redirected_to :controller => 'main', :action => 'dashboard'
  end
  
  def test_fail_authenticate
    post :authenticate, 'login' => @admin.login, 'password' => 'foo'
    assert_nil session[ :current_user_id ]
    assert_response :redirect
    assert_redirected_to :controller => 'users', :action => 'login'
    assert_equal 'You entered an invalid username and/or password.', 
                 flash[ :error]
  end
  
  def test_logout
    @request.session[ :current_user_id ] = @user.id
    get :logout
    assert_nil session[ :current_user_id ]
    assert_response :redirect
    assert_redirected_to :controller => 'users', :action => 'login'
    assert_equal 'You have been logged out', flash[ :notice ]
  end
  
  def test_no_admin_error
    @request.session[ :current_user_id ] = @user.id
    get :no_admin
    assert_template 'no_admin'
  end
end
