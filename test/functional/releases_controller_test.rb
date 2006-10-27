require File.dirname(__FILE__) + '/../test_helper'
require 'releases_controller'

# Re-raise errors caught by the controller.
class ReleasesController; def rescue_action(e) raise e end; end

class ReleasesControllerTest < Test::Unit::TestCase
  fixtures :releases

  def setup
    Project.destroy_all
    User.destroy_all
    create_common_fixtures :user_one, :project_one, :story_one, :story_two,
                           :iteration_one
    @project_one.users << @user_one
    @controller = ReleasesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:current_user] = @user_one
  end

  def test_index
    get :index, :project_id => @project_one.id
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list, :project_id => @project_one.id

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:releases)
  end

  def test_show
    get :show, :id => 1, :project_id => @project_one.id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:release)
    assert assigns(:release).valid?
  end

  def test_new
    get :new, :project_id => @project_one.id

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:release)
  end

  def test_create
    num_releases = Release.count

    post :create, 'project_id' => @project_one.id,
         'release' => { 'name' => 'New Release',
                          'goal' => 'My new release goal',
                          'release_date' => Date.today.day.to_s
                      }

    assert_response :redirect
    assert_redirected_to :action => 'list', :project_id => @project_one.id 

    assert_equal num_releases + 1, Release.count
  end

  def test_edit
    get :edit, :id => 1, :project_id => @project_one.id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:release)
    assert assigns(:release).valid?
  end

  def test_update
    post :update, :id => 1, :project_id => @project_one.id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Release.find(1)

    post :destroy, :id => 1, :project_id => @project_one.id
    assert_response :redirect
    assert_redirected_to :action => 'list', :project_id => @project_one.id

    assert_raise(ActiveRecord::RecordNotFound) {
      Release.find(1)
    }
  end
end
