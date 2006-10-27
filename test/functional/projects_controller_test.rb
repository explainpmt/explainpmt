require File.dirname(__FILE__) + '/../test_helper'
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < Test::Unit::TestCase
  fixtures :projects

  def setup
    @controller = ProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @admin      = User.find(1)
    @user       = User.find(2)
  end

  def test_index
    @request.session[ :current_user_id ] = @user.id
    get :index
    assert_response :success
    assert_template 'list'
  end
  
  def test_index_no_auth
    get :index
    assert_response :redirect
    assert_redirected_to :controller => 'users', :action => 'login'
    assert_equal "Please log in, and we'll send you right along.", flash[ :status ]
  end
  

  def test_list
    @request.session[ :current_user_id ] = @user.id
    get :list
    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:projects)
  end

  def test_show
    @request.session[ :current_user_id ] = @user.id
    get :show, :id => 1
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:project)
    assert assigns(:project).valid?
  end

  def test_new_as_user
    @request.session[ :current_user_id ] = @user.id
    get :new
    assert_response :redirect
    assert_redirected_to :action => 'no_admin'
    assert_equal 'You must be logged in as an administrator to perform'+
                  ' this action', flash[ :error ]
  end

  def test_new_as_admin
    @request.session[ :current_user_id ] = @admin.id
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:project)
  end


  def test_create_as_user
    @request.session[ :current_user_id ] = @user.id
    num_projects = Project.count
    post :create, :project => {}
    assert_response :redirect
    assert_redirected_to :action => 'no_admin'
    assert_equal 'You must be logged in as an administrator to perform'+
                  ' this action', flash[ :error ]
  end

  def test_create_as_admin
    @request.session[ :current_user_id ] = @admin.id
    num_projects = Project.count
    post :create, :project => {
      'name' => 'New Test Project'
    }
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_equal num_projects + 1, Project.count
  end

  def test_edit_as_user
    @request.session[ :current_user_id ] = @user.id
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'no_admin'
    assert_equal 'You must be logged in as an administrator to perform'+
                  ' this action', flash[ :error ]
  end

  def test_edit_as_admin
    @request.session[ :current_user_id ] = @admin.id
    get :edit, :id => 1
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:project)
    assert assigns(:project).valid?
  end

  def test_update_as_user
    @request.session[ :current_user_id ] = @user.id
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'no_admin'
    assert_equal 'You must be logged in as an administrator to perform'+
                  ' this action', flash[ :error ]
  end

  def test_update_as_admin
    @request.session[ :current_user_id ] = @admin.id
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end


  def test_destroy_as_user
    @request.session[ :current_user_id ] = @user.id
    assert_not_nil Project.find(1)
    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'no_admin'
    assert_equal 'You must be logged in as an administrator to perform'+
                  ' this action', flash[ :error ]
  end
  
  def test_destroy_as_admin
    @request.session[ :current_user_id ] = @admin.id
    assert_not_nil Project.find(2)
    post :destroy, :id => 2
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_raise(ActiveRecord::RecordNotFound) {
      Project.find(2)
    }
  end
  
  def test_create_with_no_name
    @request.session[ :current_user_id ] = @admin.id
    num_projects = Project.count
    post :create, :project => {
      'name' => nil
    }
    # The response is success because this is calling the method 'create' and
    # the validation is rejecting the nil and then reloading the 'create'
    # method.
    assert_response :success
    
    assert_tag :tag => "div", :attributes => { :class => "errorExplanation"}
    assert_tag :tag => "div", :attributes => { :class => "fieldWithErrors"}
    assert_not_equal num_projects + 1, Project.count
  end
end
