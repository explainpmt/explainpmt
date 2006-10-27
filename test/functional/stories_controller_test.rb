require File.dirname(__FILE__) + '/../test_helper'
require 'stories_controller'

# Re-raise errors caught by the controller.
class StoriesController; def rescue_action(e) raise e end; end

class StoriesControllerTest < Test::Unit::TestCase
  def setup
    Project.destroy_all
    User.destroy_all
    create_common_fixtures :user_one, :project_one, :story_one, :story_two,
                           :iteration_one
    @project_one.users << @user_one
    @story_one.project = @project_one
    @story_one.save
    @iteration_one.project = @project_one
    @iteration_one.save
    @story_two.project = @project_one
    @story_two.save
    @story_three = Story.create('title' => 'Story Three',
                                'description' => 'Story Three',
                                'priority' => Story::Priority::High,
                                'risk' => Story::Risk::High,
                                'points' => 1,
                                'status' => Story::Status::Cancelled,
                                'project_id' => @project_one.id)
    @iteration_one.stories << @story_one
    @controller = StoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:current_user] = @user_one
  end

  def test_backlog
    get :index, 'project_id' => @project_one.id
    assert_response :success
    assert_template 'index'
    assert_equal [@story_two], assigns(:stories)
  end

  def test_backlog_show_cancelled
    get :index, 'project_id' => @project_one.id, 'show_cancelled' => 1
    assert_response :success
    assert_template 'index'
    assert_equal [@story_two, @story_three], assigns(:stories)
  end

  def test_show
    get :show, 'id' => @story_one.id, 'project_id' => @project_one.id
    assert_response :success
    assert_template 'show'
    assert_equal @story_one, assigns(:story)
  end

  def test_delete
    get :delete, 'id' => @story_one.id, 'project_id' => @project_one.id
    assert_redirected_to :controller => 'stories', :action => 'index',
                         :project_id => @project_one.id.to_s
    assert_raise(ActiveRecord::RecordNotFound) { Story.find(@story_one.id) }
  end

  def test_delete_from_iteration
    get :delete, 'id' => @story_one.id, 'project_id' => @project_one.id,
        :iteration_id => @iteration_one.id
    assert_redirected_to :controller => 'iterations', :action => 'show',
                         :id => @iteration_one.id.to_s,
                         :project_id => @project_one.id.to_s
    assert_raise(ActiveRecord::RecordNotFound) { Story.find(@story_one.id) }
  end

  def test_new
    get :new, 'project_id' => @project_one.id
    assert_response :success
    assert_template 'new'
    assert_kind_of Story, assigns(:story)
    assert assigns(:story).new_record?
  end

  def test_new_from_invalid
    @request.session[:new_story] = Story.new
    test_new
    assert_nil session[:new_story]
  end

  def test_create
    num = @project_one.backlog.size
    post :create, 'project_id' => @project_one.id,
         'story' => { 'title' => 'Test Create', 'status' => 1 }
    assert_redirected_to :controller => 'stories', :action => 'index'
    assert_equal num + 1, @project_one.backlog(true).size
  end

  def test_create_invalid
    num = Story.count
    post :create, 'project_id' => @project_one.id, 'story' => { 'title' => '' }
    assert_redirected_to :controller => 'stories', :action => 'new',
                         :project_id => @project_one.id
    assert session[:new_story]
  end

  def test_edit
    get :edit, 'project_id' => @project_one.id, 'id' => @story_one.id
    assert_response :success
    assert_template 'edit'
    assert_equal @story_one, assigns(:story)
  end

  def test_edit_from_invalid
    @story_one.title = nil
    @request.session[:edit_story] = @story_one
    test_edit
    assert_nil session[:edit_story]
  end

  def test_update
    post :update, 'project_id' => @project_one.id, 'id' => @story_one.id,
         'story' => { 'title' => 'Test Update', 'status' => 1 }
    assert_redirected_to :controller => 'stories', :action => 'index'
  end
  
  def test_update_return_to_referer
    @request.session[:return_to] = '/project/1/iterations/show/1'  
    post :update, 'project_id' => @project_one.id, 'id' => @story_one.id,
         'story' => { 'title' => 'Test Update', 'status' => 1 }       
    assert_redirected_to '/project/1/iterations/show/1'
  end

  def test_update_invalid
    post :update, 'project_id' => @project_one.id, 'id' => @story_one.id,
         'story' => { 'title' => '' }
    assert_redirected_to :controller => 'stories', :action => 'edit',
                         :project_id => @project_one.id.to_s, 
                         :id => @story_one.id.to_s
    assert session[:edit_story]
  end

  def test_take_ownership
    get :take_ownership, 'id' => @story_one.id, 'project_id' => @project_one.id
    assert_redirected_to :controller => 'iterations', :action => 'show',
                         :id => @iteration_one.id.to_s,
                         :project_id => @project_one.id.to_s
    assert flash[:status]
    assert_equal @request.session[:current_user],
                 Story.find(@story_one.id).owner
  end

  def test_release_ownership
    @story_one.owner = @request.session[:current_user]
    @story_one.save

    get :release_ownership, 'id' => @story_one.id,
        'project_id' => @project_one.id
    assert_redirected_to :controller => 'iterations', :action => 'show',
                         :id => @iteration_one.id.to_s,
                         :project_id => @project_one.id.to_s
    assert flash[:status]
    assert_nil Story.find(@story_one.id).owner
  end
end
