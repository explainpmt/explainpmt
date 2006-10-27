##############################################################################
# eXPlain Project Management Tool
# Copyright (C) 2005  John Wilger <johnwilger@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##############################################################################


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
      assert_redirected_to :controller => 'users', :action => 'login'
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
    assert_equal @project_one.users, assigns(:users)
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
  
  def test_should_redirect_user_to_dashboard_after_successful_authentication
    post :authenticate, :username => @user_one.username,
      :password => @user_one.password
    assert_redirected_to :controller => 'dashboard', :action => 'index'
  end
  
  def test_should_redirect_user_to_specified_url_after_successful_authentication
    @request.session[ :return_to ] = '/foo/bar'
    post :authenticate, :username => @user_one.username,
      :password => @user_one.password
    assert_equal 'http://test.host/foo/bar', @response.redirect_url
    assert_nil session[ :return_to ]
  end
  
  def test_should_render_current_user_as_xml_after_successful_authentication
    @request.env[ 'HTTP_ACCEPT' ] = 'application/xml'
    post :authenticate, :username => @admin.username,
      :password => @admin.password
    assert_response :success
    assert_equal @admin.to_xml( :dasherize => false ), @response.body
  end
  
  def test_should_set_current_user_in_session_after_successful_authentication
    post :authenticate, :username => @user_one.username,
      :password => @user_one.password
    assert_equal @user_one, session[ :current_user ]
  end
  
  def test_should_not_set_current_user_after_authentication_failure
    post :authenticate
    assert_nil session[ :current_user ]
  end
  
  def test_should_redirect_to_login_after_authentication_failure
    post :authenticate
    assert_redirected_to :controller => 'users', :action => 'login'
  end
  
  def test_should_set_flash_error_after_authentication_failure
    post :authenticate
    assert_equal 'You entered an invalid username and/or password.',
      flash[ :error ]
  end
  
  def test_should_render_xml_error_template_after_authentication_failure
    @request.env[ 'HTTP_ACCEPT' ] = 'application/xml'
    post :authenticate
    assert_template 'shared/error'
    assert_tag :tag => 'message',
      :content => 'You entered an invalid username and/or password.'
  end
  
  def test_should_render_login_template
    get :login
    assert_response :success
    assert_template 'login'
  end
  
  def test_should_remove_current_user_from_session_on_logout
    @request.session[ :current_user ] = @user_one
    get :logout
    assert_nil session[ :current_user ]
  end
  
  def test_should_redirect_to_login_after_logout
    @request.session[ :current_user ] = @user_one
    get :logout
    assert_redirected_to :controller => 'users', :action => 'login'
  end
  
  def test_should_set_flash_status_after_logout
    @request.session[ :current_user ] = @user_one
    get :logout
    assert_equal "You have been logged out.", flash[ :status ]
  end
end
