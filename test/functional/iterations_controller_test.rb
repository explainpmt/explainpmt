require File.dirname(__FILE__)  + '/../test_helper'
require 'iterations_controller'

# Re-raise errors caught by the controller.
class IterationsController; def rescue_action(e) raise e end; end

class IterationsControllerTest < Test::Unit::TestCase
  def setup
    Project.destroy_all
    User.destroy_all
    create_common_fixtures :user_one, :project_one, :story_one, :story_two,
                           :iteration_one
    @project_one.users << @user_one
    @story_one.project = @project_one
    @story_one.save
    @story_two.project = @project_one
    @story_two.save
    @iteration_one.project = @project_one
    @iteration_one.save
    @iteration_one.stories << @story_one
    @iteration_one.stories << @story_two
    @iteration_two = Iteration.create('start_date' => Date.today + 14,
                                      'length' => 14, 'budget' => 14,
                                      'project_id' => @project_one.id)

    @controller = IterationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:current_user] = @user_one
  end

  def test_index_no_project_id
    get :index
    assert_redirected_to :controller => 'error', :action => 'index'
    assert_equal "You attempted to access a view that requires a project to " +
                 "be selected, but no project id was set in your request.",
                 flash[:error]
  end

  def test_index
    @project_one.iterations(true).clear
    past = add_iteration(@project_one, Date.today - 30, 14)
    current = add_iteration(@project_one, Date.today - 3, 14)
    future = add_iteration(@project_one, Date.today + 30, 14)
    get :index, 'project_id' => @project_one.id
    assert_redirected_to :controller => 'iterations', :action => 'show',
                         :id => current.id.to_s, :project_id => @project_one.id.to_s
    current.destroy
    get :index, 'project_id' => @project_one.id
    assert_redirected_to :controller => 'iterations', :action => 'show',
                         :id => past.id.to_s, :project_id => @project_one.id.to_s
    past.destroy
    get :index, 'project_id' => @project_one.id
    assert_redirected_to :controller => 'iterations', :action => 'show',
                         :id => future.id.to_s, :project_id => @project_one.id.to_s
    future.destroy
    get :index, 'project_id' => @project_one.id
    assert_response :success
    assert_template 'index'
  end

  def test_show
    get :show, 'id' => @iteration_one.id, 'project_id' => @project_one.id
    assert_response :success
    assert_template 'show'
    assert_equal @iteration_one, assigns(:iteration)
    assert assigns(:stories)
  end

  def test_new
    get :new, 'project_id' => @project_one.id
    assert_response :success
    assert_template 'new'
    assert assigns(:iteration).class == Iteration
    assert assigns(:iteration).new_record?
  end

  def test_new_from_invalid
    @request.session[:new_iteration] = Iteration.new
    test_new
    assert_nil session[:new_iteration]
  end

  def test_create
    Iteration.destroy_all
    post :create, 'project_id' => @project_one.id,
         'iteration' => { 'start_date(1i)' => Date.today.year.to_s,
                          'start_date(2i)' => Date.today.mon.to_s,
                          'start_date(3i)' => Date.today.day.to_s,
                          'length' => '14',
                          'budget' => '120' }
    assert_response :success
    assert_template 'layouts/refresh_parent_close_popup'
    assert_equal "A new, 14-day iteration starting on " +
                 "#{Date.today.strftime('%m/%d/%Y')} has been created.",
                 flash[:status]
    assert_equal 1, Iteration.count
  end

  def test_create_invalid
    it_count = Iteration.count
    post :create, 'project_id' => @project_one.id,
         'iteration' => { 'start_date(1i)' => Date.today.year.to_s,
                          'start_date(2i)' => Date.today.mon.to_s,
                          'start_date(3i)' => Date.today.day.to_s,
                          'length' => 'foo',
                          'budget' => 'bar' }
    assert_redirected_to :controller => 'iterations', :action => 'new',
                         :project_id => @project_one.id.to_s
    assert session[:new_iteration]
    assert_equal it_count, Iteration.count
  end

  def test_delete
    get :delete, 'id' => @iteration_one.id, 'project_id' => @project_one.id
    assert_redirected_to :controller => 'iterations', :action => 'index',
                         :project_id => @project_one.id.to_s
    assert_equal "The #{@iteration_one.length}-day iteration scheduled to " +
                 "start on #{@iteration_one.start_date.strftime('%m/%d/%Y')} " +
                 "has been deleted. All stories assigned to the iteration " +
                 "(if any) have been moved to the project backlog.",
                 flash[:status]
    assert_raise(ActiveRecord::RecordNotFound) {
      Iteration.find(@iteration_one.id)
    }
    assert_equal [], 
                 Story.find(:all,
                            :conditions => [ 'iteration_id = ?',
                                             @iteration_one.id ])
  end

  def test_edit
    get :edit, 'id' => @iteration_one.id, 'project_id' => @project_one.id
    assert_response :success
    assert_template 'edit'
    assert_equal @iteration_one, assigns(:iteration)
  end

  def test_edit_invalid
    @request.session[:edit_iteration] = @iteration_one
    test_edit
    assert_nil session[:edit_iteration]
  end

  def test_update
    post :update, 'id' => @iteration_one.id, 'project_id' => @project_one.id,
         'iteration' => { 'length' => '10' }
    assert_response :success
    assert_template 'layouts/refresh_parent_close_popup'
    assert flash[:status]
  end

  def test_update_invalid
    post :update, 'id' => @iteration_one.id, 'project_id' => @project_one.id,
         'iteration' => { 'length' => 'foo' }
    assert_redirected_to :controller => 'iterations', :action => 'edit',
                         :id => @iteration_one.id.to_s,
                         :project_id => @project_one.id.to_s
    assert session[:edit_iteration]
  end

  def test_move_stories_to_backlog
    post :move_stories, 'id' => @iteration_one.id,
         'project_id' => @project_one.id,
         'selected_stories' => [ @story_one.id, @story_two.id ], 'move_to' => 0
    assert_redirected_to :controller => 'iterations', :action => 'show',
                         :id => @iteration_one.id.to_s,
                         :project_id => @project_one.id.to_s
    sc_one = Story.find(@story_one.id)
    assert_nil sc_one.iteration
    sc_two = Story.find(@story_two.id)
    assert_nil sc_two.iteration
    assert flash[:status]
  end

  def test_move_stories_to_another_iteration
    @story_one.status = Story::Status::Defined
    @story_one.save
    @story_two.status = Story::Status::Defined
    @story_two.save
    post :move_stories, 'id' => @iteration_one.id,
         'project_id' => @project_one.id,
         'selected_stories' => [@story_one.id, @story_two.id],
         'move_to' => @iteration_two.id
    assert_redirected_to :controller => 'iterations', :action => 'show',
                         :id => @iteration_one.id.to_s,
                         :project_id => @project_one.id.to_s
    sc_one = Story.find(@story_one.id)
    assert_equal @iteration_two, sc_one.iteration
    sc_two = Story.find(@story_two.id)
    assert_equal @iteration_two, sc_two.iteration
    assert flash[:status]
  end

  def test_move_stories_raises_no_error_if_no_stories_selected
    assert_nothing_raised do
      post :move_stories, :project_id => @project_one.id,
        :move_to => @iteration_two.id
    end
  end

  def test_select_stories
    get :select_stories, 'id' => @iteration_one.id,
        'project_id' => @project_one.id
    assert_response :success
    assert_template 'select_stories'
    assert_equal @iteration_one, assigns(:iteration)
    assigns['stories'].each do |s|
      assert_nil s.iteration
      assert s.status != Story::Status::New
      assert s.status != Story::Status::Cancelled
    end
  end

  def test_assign_stories
    post :assign_stories, 'id' => @iteration_one.id,
         'project_id' => @project_one.id,
         'selected_stories' => [ @story_one.id, @story_two.id ],
         'move_to' => @iteration_two.id
    assert_response :success
    assert_template 'layouts/refresh_parent_close_popup'
    sc_one = Story.find(@story_one.id)
    assert_equal @iteration_two, sc_one.iteration
    sc_two = Story.find(@story_two.id)
    assert_equal @iteration_two, sc_two.iteration
    assert flash[:status]
  end

  def test_assign_stories_not_defined
    story = @project_one.stories.create('title' => 'undefed story')
    post :move_stories, 'project_id' => @project_one.id,
         'selected_stories' => [story.id], 'move_to' => @iteration_one.id
    assert_redirected_to :controller => 'stories', :action => 'index',
                         :project_id => @project_one.id.to_s
    assert_nil flash[:status]
    assert flash[:error]
  end

  ### Test Helpers ###
  private

  def add_iteration(project, start_date, length)
    project.iterations.create('start_date' => start_date, 'length' => length)
  end
end

