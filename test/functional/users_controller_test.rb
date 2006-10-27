require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES
  def setup
    @admin = User.find 1
    @user_one = User.find 2
    @project_one = Project.find 1

    @controller = UsersController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @request.session[ :current_user ] = @user_one
  end

  def test_authentication_required
    @request.session[ :current_user ] = nil
    actions = [ :index, :new, :create, :edit, :update, :delete ]
    actions.each do |a|
      process a
      assert_redirected_to :controller => 'session', :action => 'login'
      assert session[ :return_to ]
      assert_equal "Please log in, and we'll send you right along.",
        flash[ :status ]
    end
  end

  def test_admin_required
    actions = [ :new, :create, :edit, :update, :delete ]
    actions.each do |a|
      process a
      assert_redirected_to :controller => 'error', :action => 'index'
      assert_equal "You must be logged in as an administrator to perform " +
        "the requested action.", flash[ :error ]
    end
  end

  def test_admin_not_required_on_edit_if_id_is_session_user
    get :edit, 'id' => @user_one.id
    assert_response :success
    post :update, 'id' => @user_one.id, 'user' => {}
    assert_response :redirect
    assert_redirected_to :controller => 'dashboard'
    user = User.find @user_one.id
    assert !user.admin?
  end

  def test_admin_cannot_remove_own_admin_privileges
    @request.session[ :current_user ] = @admin
    get :edit, 'id' => @admin.id, 'user' => { 'admin' => '0' }
    assert_response :success
    user = User.find @admin.id
    assert user.admin?
  end

  def test_index
    get :index
    assert_template 'index'
    assert_equal User.find( :all,
      :order => 'last_name ASC, first_name ASC' ), assigns( :users )
  end

  def test_index_with_project_id
    @request.session[ :current_user ] = @admin
    get :index, 'project_id' => @project_one.id
    assert_template 'project'
    assert_equal @project_one, assigns( :project )
  end

  def test_new
    @request.session[ :current_user ] = @admin
    get :new
    assert_response :success
    assert_template 'new'
    assert_kind_of User, assigns( :user )
    assert assigns( :user ).new_record?
  end

  def test_new_from_invalid
    @request.session[ :current_user ] = @admin
    @request.session[ :new_user ] = User.new :last_name => 'Foo'
    get :new
    assert_kind_of User, assigns( :user )
    assert assigns( :user ).new_record?
    assert_equal 'Foo', assigns( :user ).last_name
    assert_nil session[ :new_user ]
  end

  def test_new_with_project_id
    @request.session[ :current_user ] = @admin
    get :new, 'project_id' => @project_one.id
    assert_response :success
    assert_template 'new'
    assert_kind_of User, assigns( :user )
    assert assigns( :user ).new_record?
    assert_equal @project_one, assigns( :project )
    assert_tag :tag => 'input', :attributes => { :type => 'hidden',
      :name => 'project_id', :value => @project_one.id }
  end

  def test_create
    @request.session[ :current_user ] = @admin
    num_users = User.count
    post :create, 'user' => { 'username' => 'test_create',
      'password' => 'test_create_password',
      'password_confirmation' => 'test_create_password',
      'email' => 'test_create@example.com', 'first_name' => 'Test',
      'last_name' => 'Create' }
    assert_response :redirect
    assert_redirected_to :controller => 'dashboard'
    assert_equal num_users + 1, User.count
  end

  def test_create_invalid
    @request.session[ :current_user ] = @admin
    num_users = User.count
    post :create, 'user' => {}
    assert_redirected_to :controller => 'users', :action => 'new'
    assert_kind_of User, session[ :new_user ]
    assert session[ :new_user ].new_record?
    assert_equal num_users, User.count
  end

  def test_create_with_project_id
    @request.session[ :current_user ] = @admin
    num_users = User.count
    post :create, 'project_id' => @project_one.id,
      'user' => { 'username' => 'test_create_with_project',
        'password' => 'test_create_password',
        'password_confirmation' => 'test_create_password',
        'email' => 'test_create@example.com', 'first_name' => 'Test',
        'last_name' => 'Create' }         
    assert_response :redirect
    assert_redirected_to :controller => 'dashboard'
    assert_equal num_users + 1, User.count
    user = User.find :first,
      :conditions => [ 'username = ?', 'test_create_with_project' ]  
    assert @project_one.users.include?( user )
  end

  def test_create_invalid_with_project_id
    @request.session[ :current_user ] = @admin
    num_users = User.count
    post :create, 'user' => {}, 'project_id' => @project_one.id
    assert_redirected_to :controller => 'users', :action => 'new',
      :project_id => @project_one.id
    assert_kind_of User, session[ :new_user ]
    assert session[ :new_user ].new_record?
    assert_equal num_users, User.count
  end

  def test_edit
    @request.session[ :current_user ] = @admin
    get :edit, 'id' => @user_one.id
    assert_response :success
    assert_template 'edit'
    assert_equal @user_one, assigns( :user )
  end

  def test_edit_from_invalid
    @request.session[ :current_user ] = @admin
    @user_one.username = nil
    @request.session[ :edit_user ] = @user_one
    get :edit, 'id' => @user_one.id
    assert_equal @user_one, assigns( :user )
    assert_nil session[ :edit_user ]
  end

  def test_update
    @request.session[ :current_user ] = @admin
    post :update, 'id' => @user_one.id, 'user' => { 'last_name' => 'Foo' }
    assert_response :redirect
    assert_redirected_to :controller => 'dashboard'
    assert_equal 'Foo', User.find( @user_one.id ).last_name
  end

  def test_update_invalid
    @request.session[ :current_user ] = @admin
    post :update, 'id' => @user_one.id, 'user' => { 'username' => '' }
    assert_redirected_to :controller => 'users', :action => 'edit',
      :id => @user_one.id
    @user_one.username = ''
    assert_equal @user_one, session[ :edit_user ]
  end

  def test_delete
    @request.session[ :current_user ] = @admin
    get :delete, :id => @user_one.id
    assert_raise( ActiveRecord::RecordNotFound ) do
      User.find @user_one.id
    end
  end
end
