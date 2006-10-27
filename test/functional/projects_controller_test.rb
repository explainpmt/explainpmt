require File.dirname(__FILE__) + '/../test_helper'
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < Test::Unit::TestCase
  FULL_PAGES = [:index]
  POPUPS = [:new,:create,:add_users,:update_users,:edit,:update]
  NO_RENDERS = [:remove_user,:delete]
  ALL_ACTIONS = FULL_PAGES + POPUPS + NO_RENDERS
  
  def setup
    Project.destroy_all
    User.destroy_all
    create_common_fixtures :admin, :user_one, :project_one
    @user_two = User.create 'username' => 'usertwo',
                            'password' => 'usertwopass',
                            'email' => 'usertwo@example.com',
                            'first_name' => 'User', 'last_name' => 'Two'
    @controller = ProjectsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @request.session[:current_user] = @admin
  end

  def test_authentication_required
    @request.session[:current_user] = nil
    ALL_ACTIONS.each do |a|
      process a
      assert_redirected_to :controller => 'session', :action => 'login'
      assert session[:return_to]
    end
  end

  def test_admin_required
    @request.session[:current_user] = @user_one
    ALL_ACTIONS.each do |a|
      process a
      assert_redirected_to :controller => 'error', :action => 'index'
      assert_equal "You must be logged in as an administrator to " +
                   "perform the requested action.",
                   flash[:error]
    end
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert assigns(:projects)
    assert_equal Project.find_all(nil,'name ASC'), assigns(:projects)
  end

  def test_new
    get :new
    assert_response :success
    assert_template 'new'
    assert assigns(:project)
    assert_kind_of Project, assigns(:project)
    assert assigns(:project).new_record?
  end

  def test_new_from_error
    project = Project.create
    assert !project.valid?
    @request.session[:new_project] = project
    get :new
    assert_response :success
    assert_template 'new'
    assert assigns(:project)
    assert_equal project, assigns(:project)
    assert_nil session[:new_project]
  end

  def test_create_no_membership
    num_before_create = Project.count
    mem_num_before_create = current_user.projects.size
    post :create, 'project' => { 'name' => 'Test Create',
                                 'description' => '' }
    assert_response :success
    assert_template 'layouts/refresh_parent_close_popup'
    assert_equal num_before_create + 1, Project.count
    assert_equal mem_num_before_create, current_user.projects.size
  end

  def test_create_add_membership
    num_before_create = Project.count
    mem_num_before_create = current_user.projects.size
    post :create, 'add_me' => '1', 'project' => { 'name' => 'Test Create',
                                                  'description' => '' }
    assert_response :success
    assert_template 'layouts/refresh_parent_close_popup'
    assert_equal num_before_create + 1, Project.count
    assert_equal mem_num_before_create + 1, current_user.projects.size
  end

  def test_create_with_errors
    num_before_create = Project.count
    post :create
    assert_redirected_to :controller => 'projects', :action => 'new'
    assert session[:new_project]
    assert_equal num_before_create, Project.count
  end

  def test_add_users
    get :add_users, 'project_id' => @project_one.id
    assert_response :success
    assert assigns(:project)
    assert_equal @project_one, assigns(:project)
    assert_template 'add_users'
    assert assigns(:available_users)
    assert_equal [@user_one,@user_two,@admin], assigns(:available_users)
  end

  def test_update_users
    post :update_users, 'project_id' => @project_one.id,
         'selected_users' => [@user_one.id, @user_two.id]                         
    assert_response :success
    assert_template 'layouts/refresh_parent_close_popup'
    assert flash[:status]
    [@user_one, @user_two].each do |u|
      assert @project_one.users.include?(u)
    end
  end

  def test_remove_user
    @project_one.users << @user_one
    get :remove_user, 'project_id' => @project_one.id, 'id' => @user_one.id
    assert_redirected_to :controller => 'users', :action => 'index',
                         :project_id => @project_one.id
    assert flash[:status]
    assert !@project_one.users(true).include?(@user_one)
  end

  def test_delete
    get :delete, 'id' => @project_one.id
    assert_redirected_to :controller => 'projects', :action => 'index'
    assert flash[:status]
    assert_raise(ActiveRecord::RecordNotFound) { Project.find(@project_one.id) }
  end

  def test_edit
    get :edit, 'id' => @project_one.id
    assert_response :success
    assert_template 'edit'
    assert assigns(:project)
    assert_equal @project_one, assigns(:project)
  end

  def test_edit_from_invalid
    @request.session[:edit_project] = @project_one
    get :edit, 'id' => @project_one.id
    assert_kind_of Project, assigns(:project)
    assert_equal @project_one.id, assigns(:project).id
    assert_nil session[:edit_project]
  end

  def test_update
    post :update, 'id' => @project_one.id, 'project' => { 'name' => 'Test' }
    assert_response :success
    assert_template 'layouts/refresh_parent_close_popup'
    project = Project.find(@project_one.id)
    assert_equal 'Test', project.name
  end

  def test_my_projects_list
    @project_one.users << @user_one
    project2 = Project.create('name' => 'Project Two')
    project2.users << @user_one
    @request.session[:current_user] = @user_one
    process :my_projects_list
    assert_response :success
    assert_template '_my_projects_list'
    assert assigns(:projects).include?(@project_one)
    assert assigns(:projects).include?(project2)
  end

  private

  def current_user
    User.find(@request.session[:current_user].id)
  end
end
